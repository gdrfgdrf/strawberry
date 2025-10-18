use crate::utils::get_int_vec_from_ptr;
use crate::utils::get_string_from_ptr;
use chrono::{DateTime, Local, MappedLocalTime, NaiveDateTime, ParseResult, TimeDelta};
use flutter_rust_bridge::for_generated::lazy_static;
use std::collections::HashMap;
use std::fs::File;
use std::io;
use std::io::{BufWriter, Write};
use std::num::ParseIntError;
use std::ops::Deref;
use std::path::Path;
use std::sync::{Arc, Mutex, MutexGuard, RwLock, RwLockReadGuard, RwLockWriteGuard};
use std::time::Duration;
use walkdir::{DirEntry, WalkDir};

lazy_static! {
    static ref MANAGER_INSTANCE: Arc<StrawberryLoggerManager> = Arc::new(StrawberryLoggerManager {
        _cache: Mutex::new(HashMap::new()),
    });
}

fn safe_create_folder(folder: &String) -> bool {
    let path: &Path = Path::new(folder);
    if path.exists() {
        return true;
    }
    let create_result: io::Result<()> = std::fs::create_dir_all(folder.clone());
    create_result.is_ok()
}

fn now_time_filename_string() -> String {
    let now: DateTime<Local> = Local::now();
    now.format("%Y-%m-%d_%H-%M-%S").to_string()
}

fn parse_filename_time(time_string: &String) -> Option<DateTime<Local>> {
    let parse_result: ParseResult<NaiveDateTime> =
        NaiveDateTime::parse_from_str(time_string, "%Y-%m-%d_%H-%M-%S");
    if parse_result.is_err() {
        return None;
    }
    let mapped_local_time: MappedLocalTime<DateTime<Local>> =
        parse_result.unwrap().and_local_timezone(Local);
    match mapped_local_time {
        MappedLocalTime::Single(dt) => Some(dt),
        MappedLocalTime::Ambiguous(_, _) => None,
        MappedLocalTime::None => None,
    }
}

fn now_time_pretty_string() -> String {
    let now: DateTime<Local> = Local::now();
    now.format("%Y-%m-%d %H:%M:%S").to_string()
}

fn level_prefix(level: &LogLevels) -> &str {
    match level {
        LogLevels::TRACE => "[TRACE]",
        LogLevels::DEBUG => "[DEBUG]",
        LogLevels::INFO => "[INFO]",
        LogLevels::WARN => "[WARN]",
        LogLevels::ERROR => "[ERROR]",
        LogLevels::FATAL => "[FATAL]",
    }
}

#[unsafe(no_mangle)]
pub extern "C" fn delete_timeout_log_files(
    folder_ptr: *const u8,
    folder_len: u32,
    timeout_days: u32,
) {
    let folder_option: Option<String> = get_string_from_ptr(folder_ptr, folder_len);
    if folder_option.is_none() {
        return;
    }
    let folder: String = folder_option.unwrap();

    let path: &Path = Path::new(&folder);
    if !path.exists() {
        return;
    }

    if !path.is_dir() {
        panic!("specified file {} is not a directory", folder);
    }

    let timeout: Duration = Duration::from_secs((timeout_days * 24 * 60 * 60) as u64);
    let now: DateTime<Local> = Local::now();
    let timeout_delta_option: Option<TimeDelta> =
        TimeDelta::try_milliseconds(timeout.as_millis() as i64);
    if timeout_delta_option.is_none() {
        panic!("convert duration to time delta error")
    }
    let timeout_delta: TimeDelta = timeout_delta_option.unwrap();

    let mut walk_dir: WalkDir = WalkDir::new(folder);
    walk_dir = walk_dir.max_depth(3);

    for entry_result in walk_dir {
        if entry_result.is_err() {
            continue;
        }
        let entry: DirEntry = entry_result.unwrap();
        let entry_path: &Path = entry.path();
        if !entry_path.is_file() {
            continue;
        }

        let filename_convert_result: Option<&str> = entry.file_name().to_str();
        if filename_convert_result.is_none() {
            continue;
        }
        let filename: &str = filename_convert_result.unwrap();

        let logfile_option: Option<LogFile> = LogFile::parse(String::from(filename));
        if logfile_option.is_none() {
            continue;
        }

        let logfile: LogFile = logfile_option.unwrap();
        let delta: TimeDelta = now.signed_duration_since(&logfile.date_time);

        if (delta >= timeout_delta) {
            let full_path_option: Option<&str> = entry.path().to_str();
            if full_path_option.is_none() {
                continue;
            }
            let full_path: &str = full_path_option.unwrap();
            let _ = std::fs::remove_file(full_path.to_string());
        }
    }
}

#[derive(PartialEq, Eq, Clone)]
pub enum LogLevels {
    TRACE,
    DEBUG,
    INFO,
    WARN,
    ERROR,
    FATAL,
}

pub struct LogFile {
    channel_name: String,
    service_name: Option<String>,
    filename: String,
    date_time: DateTime<Local>,
    rotation_count: isize,
}

pub struct LogEvent {
    pub level: LogLevels,
    pub line: String,
}

#[derive(Clone)]
pub struct LoggerSettings {
    _folder: String,
    _max_lines: isize,
    _flush_threshold: isize,
    _save_duration: isize,
}

pub struct LogOutputFactory;

pub struct DefaultLogOutput {
    _settings: Arc<LoggerSettings>,
    _channel_name: Arc<String>,
    _service_name: Option<Arc<String>>,

    _initial_time_string: Option<String>,
    _current_rotation_count: Option<isize>,
    _buf_writer: Option<BufWriter<File>>,
    _total_line_count: Option<isize>,
    _current_line_count: Option<isize>,
}

pub trait LogOutput {
    fn new(settings: LoggerSettings, channel_name: String, service_name: Option<String>) -> Self
    where
        Self: Sized;

    fn settings(&self) -> Arc<LoggerSettings>;
    fn channel_name(&self) -> Arc<String>;
    fn service_name(&self) -> Option<Arc<String>>;
    fn immediate_flush(&self) -> Arc<RwLock<Vec<LogLevels>>>;

    fn open(&mut self, time_string: String);
    fn write(&mut self, log_event: &LogEvent);
    fn rotate(&mut self);
    fn flush(&mut self);
    fn close(&mut self);
    fn goodbye(&mut self) {
        self.close();
    }
}

pub struct StrawberryLoggerFactory;

pub struct StrawberryLoggerManager {
    _cache: Mutex<HashMap<String, Arc<StrawberryLogger>>>,
}

pub struct StrawberryBasicLogger {
    _output: Option<Box<dyn LogOutput>>,
}

pub struct StrawberryLogger {
    _basic_logger: Arc<Mutex<StrawberryBasicLogger>>,
    _service: Mutex<HashMap<String, Arc<StrawberryServiceLogger>>>,
}

pub struct StrawberryServiceLogger {
    _basic_logger: Arc<Mutex<StrawberryBasicLogger>>,
}

impl LogFile {
    pub fn new(
        channel_name: String,
        service_name: Option<String>,
        filename: String,
        date_time: DateTime<Local>,
        rotation_count: isize,
    ) -> Self {
        LogFile {
            channel_name,
            service_name,
            filename,
            date_time,
            rotation_count,
        }
    }

    // {channel_name}.{%Y-%m-%d_%H-%M-%S}.{rotation-count}.log
    // {channel_name}.{service_name}.{%Y-%m-%d_%H-%M-%S}.{rotation-count}.log
    pub fn parse(filename: String) -> Option<LogFile> {
        let mut split: Vec<String> = filename
            .split(".")
            .map(move |string: &str| string.to_string())
            .collect();
        if split.len() != 4 && split.len() != 5 {
            return None;
        }
        split.pop();

        let rotation_count_string_option: Option<String> = split.pop();
        let time_string_option: Option<String> = split.pop();
        let service_name_option: Option<String>;
        if split.len() == 5 {
            service_name_option = split.pop();
        } else {
            service_name_option = None;
        }
        let channel_name_option: Option<String> = split.pop();

        if channel_name_option.is_none()
            || time_string_option.is_none()
            || rotation_count_string_option.is_none()
        {
            return None;
        }
        if split.len() == 5 && service_name_option.is_none() {
            return None;
        }

        let channel_name: String = channel_name_option.unwrap();
        let time_string: String = time_string_option.unwrap();
        let rotation_count_string: String = rotation_count_string_option.unwrap();
        let rotation_count: Result<isize, ParseIntError> = rotation_count_string.parse::<isize>();

        if channel_name.is_empty()
            || time_string.is_empty()
            || rotation_count_string.is_empty()
            || rotation_count.is_err()
        {
            return None;
        }

        let parsed_date_time_option: Option<DateTime<Local>> = parse_filename_time(&time_string);
        if parsed_date_time_option.is_none() {
            return None;
        }

        let parsed_date_time: DateTime<Local> = parsed_date_time_option.unwrap();

        Some(LogFile::new(
            channel_name,
            service_name_option,
            filename,
            parsed_date_time,
            rotation_count.unwrap(),
        ))
    }
}

impl LoggerSettings {
    pub fn new(folder: String) -> Self {
        LoggerSettings {
            _folder: folder,
            _max_lines: 500,
            _flush_threshold: 10,
            _save_duration: 7,
        }
    }

    pub fn folder(&self) -> &String {
        &self._folder
    }

    pub fn max_lines(&self) -> &isize {
        &self._max_lines
    }

    pub fn flush_threshold(&self) -> &isize {
        &self._flush_threshold
    }

    pub fn save_duration(&self) -> &isize {
        &self._save_duration
    }
}

impl LogOutputFactory {
    pub fn create_default(
        settings: LoggerSettings,
        channel_name: String,
        service_name: Option<String>,
    ) -> Box<dyn LogOutput> {
        Box::new(DefaultLogOutput::new(settings, channel_name, service_name))
    }
}

impl DefaultLogOutput {
    pub fn total_line_count(&self) -> Option<&isize> {
        match &self._total_line_count {
            None => None,
            Some(number) => Some(number),
        }
    }

    pub fn increase_total_line_count(&mut self) {
        let current: isize = self._total_line_count.unwrap();
        self._total_line_count = Some(current + 1);
    }

    pub fn reset_total_line_count(&mut self) {
        self._total_line_count = Some(0);
    }

    pub fn current_line_count(&self) -> Option<&isize> {
        match &self._current_line_count {
            None => None,
            Some(number) => Some(number),
        }
    }

    pub fn increase_current_line_count(&mut self) {
        let current: isize = self._current_line_count.unwrap();
        self._current_line_count = Some(current + 1);
    }

    pub fn reset_current_line_count(&mut self) {
        self._current_line_count = Some(0);
    }

    pub fn initial_time_string(&self) -> Option<&String> {
        match &self._initial_time_string {
            None => None,
            Some(string) => Some(string),
        }
    }

    pub fn current_rotation_count(&self) -> Option<&isize> {
        match &self._current_rotation_count {
            None => None,
            Some(number) => Some(number),
        }
    }

    pub fn increase_rotation_count(&mut self) {
        let current: isize = self._current_rotation_count.unwrap();
        self._current_rotation_count = Some(current + 1);
    }

    pub fn destroy_writer(&mut self) {
        self._buf_writer = None;
    }

    pub fn writer(&mut self) -> Option<&mut BufWriter<File>> {
        self._buf_writer.as_mut()
    }

    pub fn write_string(&mut self, string: &String) {
        let writer_option: Option<&mut BufWriter<File>> = self.writer();

        if writer_option.is_some() {
            let writer: &mut BufWriter<File> = writer_option.unwrap();
            let _ = writer.write_all(string.as_bytes());
        }
    }

    pub fn flush(&mut self) {
        let writer_option: Option<&mut BufWriter<File>> = self.writer();
        if writer_option.is_none() {
            return;
        }
        let _ = writer_option.unwrap().flush();
    }

    pub fn destroy(&mut self) {
        let writer_option: Option<&mut BufWriter<File>> = self.writer();
        if writer_option.is_none() {
            return;
        }
        let writer: &mut BufWriter<File> = writer_option.unwrap();
        let _ = writer.flush();
        let _ = writer.get_ref().sync_all();
        self.destroy_writer();
    }
}

impl LogOutput for DefaultLogOutput {
    fn new(settings: LoggerSettings, channel_name: String, service_name: Option<String>) -> Self {
        DefaultLogOutput {
            _settings: Arc::new(settings),
            _channel_name: Arc::new(channel_name),
            _service_name: if service_name.is_none() {
                None
            } else {
                Some(Arc::new(service_name.unwrap()))
            },
            _initial_time_string: None,
            _current_rotation_count: Some(1),
            _buf_writer: None,
            _total_line_count: Some(0),
            _current_line_count: Some(0),
        }
    }

    fn settings(&self) -> Arc<LoggerSettings> {
        Arc::clone(&self._settings)
    }

    fn channel_name(&self) -> Arc<String> {
        Arc::clone(&self._channel_name)
    }

    fn service_name(&self) -> Option<Arc<String>> {
        match &self._service_name {
            None => None,
            Some(service_name) => Some(Arc::clone(service_name)),
        }
    }

    fn immediate_flush(&self) -> Arc<RwLock<Vec<LogLevels>>> {
        Arc::clone(&GLOBAL_IMMEDIATE_FLUSH)
    }

    fn open(&mut self, time_string: String) {
        if self._buf_writer.is_some() {
            panic!("this output is already opened")
        }
        self.reset_total_line_count();
        self._initial_time_string = Some(time_string);

        let folder: &str = &self.settings().folder().to_string();
        let channel_name: &str = &self.channel_name().to_string();
        let initial_time_string: &str = &self.initial_time_string().unwrap().to_string();
        let current_rotation_count: &str = &self.current_rotation_count().unwrap().to_string();
        let filename: String;

        if self.service_name().is_none() {
            filename = format!(
                "{}/{}.{}.{}.log",
                folder, channel_name, initial_time_string, current_rotation_count
            );
        } else {
            let service_name: &str = &self.service_name().unwrap();
            filename = format!(
                "{}/{}.{}.{}.{}.log",
                folder, channel_name, service_name, initial_time_string, current_rotation_count
            );
        }

        let file_result: io::Result<File> = File::create(filename);
        if file_result.is_err() {
            panic!("create file error: {}", file_result.err().unwrap())
        }

        let writer: BufWriter<File> = BufWriter::with_capacity(1024 * 1024, file_result.unwrap());
        self._buf_writer = Some(writer);

        let initial_line: String;
        if self.service_name().is_none() {
            initial_line = format!(
                "rotation: {}, first time: {}",
                current_rotation_count, initial_time_string
            );
        } else {
            let service_name: &str = &self.service_name().unwrap();
            initial_line = format!(
                "service: {}, rotation: {}, first time: {}",
                service_name, current_rotation_count, initial_time_string
            );
        }

        let built_initial_line: String = format!(
            "{}: [INITIAL] strawberry logger for channel: {}, {}\n",
            now_time_pretty_string(),
            channel_name,
            initial_line
        );

        self.write_string(&built_initial_line);
        self.flush();
    }

    fn write(&mut self, log_event: &LogEvent) {
        if self.writer().is_none() {
            panic!("output is not opened")
        }
        let enabled_levels: RwLockReadGuard<Vec<LogLevels>> = GLOBAL_ENABLED_LEVELS.read().unwrap();
        let level: &LogLevels = &log_event.level;
        if !enabled_levels.contains(level) {
            return;
        }

        let now_time_string: String = now_time_pretty_string();

        if self.total_line_count().unwrap() >= self.settings().max_lines() {
            let target_rotation_count: isize = self.current_rotation_count().unwrap() + 1;
            let built_rotation_string: String = format!(
                "{}: [ROTATION] turning to next rotation file: {}\n",
                now_time_string, target_rotation_count
            );
            self.write_string(&built_rotation_string);
            self.flush();
            self.rotate();
        }

        let line: &String = &log_event.line;
        let built: String = format!("{}: {}", now_time_string, line);

        self.increase_total_line_count();
        self.increase_current_line_count();

        self.write_string(&built);

        let current_immediate_flush: Arc<RwLock<Vec<LogLevels>>> = self.immediate_flush();
        let current_immediate_flush: RwLockReadGuard<Vec<LogLevels>> =
            current_immediate_flush.read().unwrap();
        if current_immediate_flush.contains(level) {
            self.flush();
            return;
        }
        if self.current_line_count().unwrap() >= self.settings().flush_threshold() {
            self.flush();
        }
    }

    fn rotate(&mut self) {
        self.close();
        self.increase_rotation_count();
        self.open(self.initial_time_string().unwrap().to_string());
    }

    fn flush(&mut self) {
        if self.writer().is_none() {
            panic!("output is not opened")
        }
        let _ = self.writer().unwrap().flush();
        self.reset_current_line_count();
    }

    fn close(&mut self) {
        if self.writer().is_none() {
            return;
        }
        let built_goodbye_string: String = format!(
            "{}: [GOODBYE] the output is closing\n",
            now_time_pretty_string()
        );
        self.write_string(&built_goodbye_string);
        self.destroy();

        self.reset_current_line_count();
        self.reset_total_line_count();
    }
}

impl StrawberryLoggerFactory {
    pub fn create_default(folder: String, channel_name: String) -> Option<Arc<StrawberryLogger>> {
        let built_folder: String = format!("{}/{}", &folder, &channel_name);
        let create_result: bool = safe_create_folder(&built_folder);
        if !create_result {
            return None;
        }

        let settings: LoggerSettings = LoggerSettings::new(built_folder);
        let logger: Arc<StrawberryLogger> = StrawberryLogger::new(settings, channel_name);
        Some(logger)
    }
}

impl StrawberryLoggerManager {
    fn instance() -> Arc<StrawberryLoggerManager> {
        Arc::clone(MANAGER_INSTANCE.deref())
    }

    fn cache_logger(&self, channel_name: String, logger: Arc<StrawberryLogger>) {
        let mut cache_map: MutexGuard<HashMap<String, Arc<StrawberryLogger>>> =
            self._cache.lock().unwrap();
        cache_map.insert(channel_name, logger);
    }

    fn cached_logger(&self, channel_name: &String) -> Option<Arc<StrawberryLogger>> {
        let cache_map: MutexGuard<HashMap<String, Arc<StrawberryLogger>>> =
            self._cache.lock().unwrap();
        let option: Option<&Arc<StrawberryLogger>> = cache_map.get(channel_name);
        if option.is_none() {
            return None;
        }
        let logger = option.unwrap();
        Some(Arc::clone(logger))
    }

    fn remove_logger(&self, channel_name: &String) {
        let mut cache_map: MutexGuard<HashMap<String, Arc<StrawberryLogger>>> =
            self._cache.lock().unwrap();
        cache_map.remove(channel_name);
    }

    fn cache_service_logger(
        &self,
        channel_name: String,
        service_name: String,
        service_logger: Arc<StrawberryServiceLogger>,
    ) {
        let logger_option: Option<Arc<StrawberryLogger>> = self.cached_logger(&channel_name);
        if logger_option.is_none() {
            return;
        }
        let logger: Arc<StrawberryLogger> = logger_option.unwrap();
        logger.add_service(service_name, service_logger);
    }

    fn cached_service_logger(
        &self,
        channel_name: &String,
        service_name: &String,
    ) -> Option<Arc<StrawberryServiceLogger>> {
        let logger_option: Option<Arc<StrawberryLogger>> = self.cached_logger(&channel_name);
        if logger_option.is_none() {
            return None;
        }
        let logger: Arc<StrawberryLogger> = logger_option.unwrap();
        logger.get_service(service_name)
    }

    fn remove_service_logger(&self, channel_name: &String, service_name: &String) {
        let logger_option: Option<Arc<StrawberryLogger>> = self.cached_logger(channel_name);
        if logger_option.is_none() {
            return;
        }
        let logger: Arc<StrawberryLogger> = logger_option.unwrap();
        logger.remove_service(service_name)
    }

    fn clear_service_logger(&self, channel_name: &String) {
        let logger_option: Option<Arc<StrawberryLogger>> = self.cached_logger(channel_name);
        if logger_option.is_none() {
            return;
        }
        let logger: Arc<StrawberryLogger> = logger_option.unwrap();
        logger.clear_service()
    }

    fn goodbye_all(&self) {
        self._cache.lock().unwrap().values_mut().for_each(|logger| {
            logger.goodbye();
        })
    }

    fn goodbye_all_service(&self) {
        self._cache.lock().unwrap().values_mut().for_each(|logger| {
            logger.clear_service();
        })
    }
}

impl StrawberryBasicLogger {
    pub fn new(
        settings: LoggerSettings,
        channel_name: String,
        service_name: Option<String>,
        immediate_flush: Option<Vec<LogLevels>>,
    ) -> Self {
        let mut output: Box<dyn LogOutput> =
            LogOutputFactory::create_default(settings, channel_name, service_name);
        let filename: String = now_time_filename_string();
        output.open(filename);

        StrawberryBasicLogger {
            _output: Some(output),
        }
    }

    pub fn output(&mut self) -> Option<&mut Box<dyn LogOutput>> {
        self._output.as_mut()
    }

    pub fn settings(&mut self) -> Arc<LoggerSettings> {
        Arc::clone(&self.output().unwrap().settings())
    }

    pub fn channel_name(&mut self) -> Arc<String> {
        Arc::clone(&self.output().unwrap().channel_name())
    }

    pub fn service_name(&mut self) -> Option<Arc<String>> {
        let service_name_option = self.output().unwrap().service_name();
        if service_name_option.is_none() {
            return None;
        }
        Some(Arc::clone(&service_name_option.unwrap()))
    }

    pub fn log(&mut self, level: &LogLevels, line: &String) {
        let output_option: Option<&mut Box<dyn LogOutput>> = self.output();
        if output_option.is_none() {
            panic!("impossible error, output is error")
        }

        let level_clone: LogLevels = level.clone();
        let prefix: &str = level_prefix(&level);
        let built_line: String = format!("{} {}\n", prefix, line);
        let event: LogEvent = LogEvent {
            level: level_clone,
            line: built_line,
        };
        output_option.unwrap().write(&event);
    }

    pub fn trace(&mut self, line: &String) {
        self.log(&LogLevels::TRACE, line);
    }

    pub fn debug(&mut self, line: &String) {
        self.log(&LogLevels::DEBUG, line);
    }

    pub fn info(&mut self, line: &String) {
        self.log(&LogLevels::INFO, line);
    }

    pub fn warn(&mut self, line: &String) {
        self.log(&LogLevels::WARN, line);
    }

    pub fn error(&mut self, line: &String) {
        self.log(&LogLevels::ERROR, line);
    }

    pub fn fatal(&mut self, line: &String) {
        self.log(&LogLevels::FATAL, line);
    }

    pub fn goodbye(&mut self) {
        let output_option: Option<&mut Box<dyn LogOutput>> = self.output();
        if output_option.is_none() {
            return;
        }
        let output: &mut Box<dyn LogOutput> = output_option.unwrap();
        output.goodbye();
    }
}

impl StrawberryLogger {
    pub fn new(settings: LoggerSettings, channel_name: String) -> Arc<Self> {
        let cache_result: Option<Arc<StrawberryLogger>> =
            MANAGER_INSTANCE.cached_logger(&channel_name);
        if let Some(cached) = cache_result {
            return cached;
        }

        let logger: Arc<StrawberryLogger> = Arc::new(StrawberryLogger {
            _basic_logger: Arc::new(Mutex::new(StrawberryBasicLogger::new(
                settings,
                channel_name.clone(),
                None,
                None,
            ))),
            _service: Mutex::new(HashMap::new()),
        });

        StrawberryLoggerManager::instance().cache_logger(channel_name, Arc::clone(&logger));
        logger
    }

    pub fn basic_logger(&self) -> Arc<Mutex<StrawberryBasicLogger>> {
        Arc::clone(&self._basic_logger)
    }

    pub fn settings(&self) -> Arc<LoggerSettings> {
        let logger: Arc<Mutex<StrawberryBasicLogger>> = self.basic_logger();
        let mut logger = logger.lock().unwrap();
        logger.settings()
    }

    pub fn channel_name(&self) -> Arc<String> {
        let logger: Arc<Mutex<StrawberryBasicLogger>> = self.basic_logger();
        let mut logger = logger.lock().unwrap();
        logger.channel_name()
    }

    pub fn log(&self, level: &LogLevels, line: &String) {
        let logger: Arc<Mutex<StrawberryBasicLogger>> = self.basic_logger();
        let mut logger = logger.lock().unwrap();
        logger.log(level, line)
    }

    pub fn log_string(&self, level: &LogLevels, line: &str) {
        self.log(level, &String::from(line))
    }

    pub fn trace(&self, line: &String) {
        self.log(&LogLevels::TRACE, line);
    }

    pub fn trace_string(&self, line: &str) {
        self.log(&LogLevels::TRACE, &String::from(line));
    }

    pub fn debug(&self, line: &String) {
        self.log(&LogLevels::DEBUG, line);
    }

    pub fn debug_string(&self, line: &str) {
        self.log(&LogLevels::DEBUG, &String::from(line));
    }

    pub fn info(&self, line: &String) {
        self.log(&LogLevels::INFO, line);
    }

    pub fn info_string(&self, line: &str) {
        self.log(&LogLevels::INFO, &String::from(line));
    }

    pub fn warn(&self, line: &String) {
        self.log(&LogLevels::WARN, line);
    }

    pub fn warn_string(&self, line: &str) {
        self.log(&LogLevels::WARN, &String::from(line));
    }

    pub fn error(&self, line: &String) {
        self.log(&LogLevels::ERROR, line);
    }

    pub fn error_string(&self, line: &str) {
        self.log(&LogLevels::ERROR, &String::from(line));
    }

    pub fn fatal(&self, line: &String) {
        self.log(&LogLevels::FATAL, line);
    }

    pub fn fatal_string(&self, line: &str) {
        self.log(&LogLevels::FATAL, &String::from(line));
    }

    pub fn open_service(&self, service_name: &String) -> Option<Arc<StrawberryServiceLogger>> {
        let cache_result: Option<Arc<StrawberryServiceLogger>> =
            StrawberryLoggerManager::instance()
                .cached_service_logger(self.channel_name().as_ref(), &service_name);
        if cache_result.is_some() {
            return cache_result;
        }

        self.info(&format!("opening service: {}", service_name));

        let basic_logger: Arc<Mutex<StrawberryBasicLogger>> = self.basic_logger();
        let mut basic_logger: MutexGuard<StrawberryBasicLogger> = basic_logger.lock().unwrap();
        let settings: Arc<LoggerSettings> = basic_logger.settings().clone();

        let built_service_folder: String = format!("{}/{}", settings._folder, service_name);
        let create_result: bool = safe_create_folder(&built_service_folder);
        if !create_result {
            return None;
        }

        let channel_name: Arc<String> = basic_logger.channel_name().clone();
        let service_settings: LoggerSettings = LoggerSettings::new(built_service_folder);
        let service_logger: StrawberryServiceLogger = StrawberryServiceLogger::new(
            service_settings,
            channel_name.as_ref().clone(),
            service_name.clone(),
        );

        let wrapped_service_logger: Arc<StrawberryServiceLogger> = Arc::new(service_logger);
        StrawberryLoggerManager::instance().cache_service_logger(
            channel_name.as_ref().clone(),
            service_name.clone(),
            Arc::clone(&wrapped_service_logger),
        );
        Some(wrapped_service_logger)
    }

    pub fn get_service(&self, service_name: &String) -> Option<Arc<StrawberryServiceLogger>> {
        let service_map: MutexGuard<HashMap<String, Arc<StrawberryServiceLogger>>> =
            self._service.lock().unwrap();
        let option: Option<&Arc<StrawberryServiceLogger>> = service_map.get(service_name);
        if option.is_none() {
            return None;
        }
        Some(Arc::clone(option.unwrap()))
    }

    pub fn add_service(&self, service_name: String, service_logger: Arc<StrawberryServiceLogger>) {
        let mut service_map: MutexGuard<HashMap<String, Arc<StrawberryServiceLogger>>> =
            self._service.lock().unwrap();
        service_map.insert(service_name, service_logger);
    }

    pub fn remove_service(&self, service_name: &String) {
        let mut service_map: MutexGuard<HashMap<String, Arc<StrawberryServiceLogger>>> =
            self._service.lock().unwrap();
        service_map.remove(service_name);
    }

    pub fn clear_service(&self) {
        let mut service_map: MutexGuard<HashMap<String, Arc<StrawberryServiceLogger>>> =
            self._service.lock().unwrap();
        service_map.clear();
    }

    pub fn goodbye(&self) {
        StrawberryLoggerManager::instance().remove_logger(self.channel_name().as_ref());
        self.basic_logger().lock().unwrap().goodbye();
    }
}

impl StrawberryServiceLogger {
    pub fn new(settings: LoggerSettings, channel_name: String, service_name: String) -> Self {
        StrawberryServiceLogger {
            _basic_logger: Arc::new(Mutex::new(StrawberryBasicLogger::new(
                settings,
                channel_name,
                Some(service_name),
                None,
            ))),
        }
    }

    pub fn basic_logger(&self) -> Arc<Mutex<StrawberryBasicLogger>> {
        Arc::clone(&self._basic_logger)
    }

    pub fn settings(&self) -> Arc<LoggerSettings> {
        let logger: Arc<Mutex<StrawberryBasicLogger>> = self.basic_logger();
        let mut logger: MutexGuard<StrawberryBasicLogger> = logger.lock().unwrap();
        logger.settings()
    }

    pub fn channel_name(&self) -> Arc<String> {
        let logger: Arc<Mutex<StrawberryBasicLogger>> = self.basic_logger();
        let mut logger: MutexGuard<StrawberryBasicLogger> = logger.lock().unwrap();
        logger.channel_name()
    }

    pub fn service_name(&self) -> Option<Arc<String>> {
        match self.basic_logger().lock().unwrap().service_name() {
            None => None,
            Some(service_name) => Some(service_name),
        }
    }

    pub fn log(&self, level: &LogLevels, line: &String) {
        let logger: Arc<Mutex<StrawberryBasicLogger>> = self.basic_logger();
        let mut logger = logger.lock().unwrap();
        logger.log(level, line)
    }

    pub fn log_string(&self, level: &LogLevels, line: &str) {
        self.log(level, &String::from(line))
    }

    pub fn trace(&self, line: &String) {
        self.log(&LogLevels::TRACE, line);
    }

    pub fn trace_string(&self, line: &str) {
        self.log(&LogLevels::TRACE, &String::from(line));
    }

    pub fn debug(&self, line: &String) {
        self.log(&LogLevels::DEBUG, line);
    }

    pub fn debug_string(&self, line: &str) {
        self.log(&LogLevels::DEBUG, &String::from(line));
    }

    pub fn info(&self, line: &String) {
        self.log(&LogLevels::INFO, line);
    }

    pub fn info_string(&self, line: &str) {
        self.log(&LogLevels::INFO, &String::from(line));
    }

    pub fn warn(&self, line: &String) {
        self.log(&LogLevels::WARN, line);
    }

    pub fn warn_string(&self, line: &str) {
        self.log(&LogLevels::WARN, &String::from(line));
    }

    pub fn error(&self, line: &String) {
        self.log(&LogLevels::ERROR, line);
    }

    pub fn error_string(&self, line: &str) {
        self.log(&LogLevels::ERROR, &String::from(line));
    }

    pub fn fatal(&self, line: &String) {
        self.log(&LogLevels::FATAL, line);
    }

    pub fn fatal_string(&self, line: &str) {
        self.log(&LogLevels::FATAL, &String::from(line));
    }

    pub fn goodbye(&self) {
        StrawberryLoggerManager::instance()
            .clear_service_logger(self.service_name().as_ref().unwrap());
        self.basic_logger().lock().unwrap().goodbye()
    }
}

unsafe impl Send for StrawberryLogger {}
unsafe impl Sync for StrawberryLogger {}

unsafe impl Send for StrawberryServiceLogger {}
unsafe impl Sync for StrawberryServiceLogger {}

#[unsafe(no_mangle)]
pub extern "C" fn goodbye_log(
    logger_type: u32,
    channel_name_ptr: *const u8,
    channel_name_len: u32,
    service_name_ptr: *const u8,
    service_name_len: u32,
) {
    if logger_type != 0 && logger_type != 1 {
        return;
    }

    let channel_name_option: Option<String> =
        get_string_from_ptr(channel_name_ptr, channel_name_len);
    let service_name_option: Option<String> =
        get_string_from_ptr(service_name_ptr, service_name_len);

    if channel_name_option.is_none() {
        return;
    }
    if logger_type == 1 && service_name_option.is_none() {
        return;
    }
    let channel_name: String = channel_name_option.unwrap();

    match logger_type {
        0 => {
            let manager: Arc<StrawberryLoggerManager> = StrawberryLoggerManager::instance();
            let logger_option: Option<Arc<StrawberryLogger>> = manager.cached_logger(&channel_name);
            if logger_option.is_none() {
                return;
            }
            let logger: Arc<StrawberryLogger> = logger_option.unwrap();
            logger.clear_service();
            logger.goodbye();
        }
        1 => {
            let manager: Arc<StrawberryLoggerManager> = StrawberryLoggerManager::instance();
            let service_name: String = service_name_option.unwrap();
            let cache_option: Option<Arc<StrawberryServiceLogger>> =
                manager.cached_service_logger(&channel_name, &service_name);
            if cache_option.is_none() {
                return;
            }
            let service_logger: Arc<StrawberryServiceLogger> = cache_option.unwrap();
            service_logger.goodbye()
        }
        _ => {}
    }
}

#[unsafe(no_mangle)]
pub extern "C" fn goodbye_all() {
    StrawberryLoggerManager::instance().goodbye_all();
}

lazy_static! {
    static ref GLOBAL_IMMEDIATE_FLUSH: Arc<RwLock<Vec<LogLevels>>> =
        Arc::new(RwLock::new(Vec::new()));
    static ref GLOBAL_ENABLED_LEVELS: Arc<RwLock<Vec<LogLevels>>> =
        Arc::new(RwLock::new(Vec::new()));
}

fn parse_log_level(num: &u32) -> LogLevels {
    match num {
        0 => LogLevels::TRACE,
        1 => LogLevels::DEBUG,
        2 => LogLevels::INFO,
        3 => LogLevels::WARN,
        4 => LogLevels::ERROR,
        5 => LogLevels::FATAL,
        _ => LogLevels::INFO,
    }
}

#[unsafe(no_mangle)]
pub extern "C" fn initialize_log() {
    let mut immediate_flush: RwLockWriteGuard<Vec<LogLevels>> =
        GLOBAL_IMMEDIATE_FLUSH.write().unwrap();
    let mut enabled_levels: RwLockWriteGuard<Vec<LogLevels>> =
        GLOBAL_ENABLED_LEVELS.write().unwrap();
    immediate_flush.push(LogLevels::TRACE);
    enabled_levels.push(LogLevels::TRACE);

    immediate_flush.push(LogLevels::DEBUG);
    enabled_levels.push(LogLevels::DEBUG);

    immediate_flush.push(LogLevels::INFO);
    enabled_levels.push(LogLevels::INFO);

    immediate_flush.push(LogLevels::WARN);
    enabled_levels.push(LogLevels::WARN);

    immediate_flush.push(LogLevels::ERROR);
    enabled_levels.push(LogLevels::ERROR);

    immediate_flush.push(LogLevels::FATAL);
    enabled_levels.push(LogLevels::FATAL);
}

#[unsafe(no_mangle)]
pub extern "C" fn set_immediate_flush(vec_ptr: *mut u8, vec_len: u32) {
    let parsed_option: Option<Vec<i32>> = get_int_vec_from_ptr(vec_ptr as *mut i32, &vec_len);
    if parsed_option.is_none() {
        return;
    }
    let parsed: Vec<i32> = parsed_option.unwrap();

    let mut levels: Vec<LogLevels> = Vec::new();
    parsed.iter().for_each(|int| {
        let log_level: LogLevels = parse_log_level(&int.cast_unsigned());
        levels.push(log_level);
    });

    let mut global_immediate_flush: RwLockWriteGuard<Vec<LogLevels>> =
        GLOBAL_IMMEDIATE_FLUSH.write().unwrap();
    global_immediate_flush.clear();
    global_immediate_flush.extend(levels);
}

#[unsafe(no_mangle)]
pub extern "C" fn set_enabled_levels(vec_ptr: *mut u8, vec_len: u32) {
    let parsed_option: Option<Vec<i32>> = get_int_vec_from_ptr(vec_ptr as *mut i32, &vec_len);
    if parsed_option.is_none() {
        return;
    }
    let parsed: Vec<i32> = parsed_option.unwrap();

    let mut levels: Vec<LogLevels> = Vec::new();
    parsed.iter().for_each(|int| {
        let log_level: LogLevels = parse_log_level(&int.cast_unsigned());
        levels.push(log_level);
    });

    let mut global_enabled_levels: RwLockWriteGuard<Vec<LogLevels>> =
        GLOBAL_ENABLED_LEVELS.write().unwrap();
    global_enabled_levels.clear();
    global_enabled_levels.extend(levels.clone());
}

#[unsafe(no_mangle)]
pub extern "C" fn efficient_log(
    logger_type: u32, // 0: 主日志, 1: 服务日志
    folder_ptr: *const u8,
    folder_len: u32,
    channel_name_ptr: *const u8,
    channel_name_len: u32,
    service_name_ptr: *const u8,
    service_name_len: u32,
    level: u32,
    message_ptr: *const u8,
    message_len: u32,
) {
    if logger_type != 0 && logger_type != 1 {
        return;
    }

    let folder_option: Option<String> = get_string_from_ptr(folder_ptr, folder_len);
    let channel_name_option: Option<String> =
        get_string_from_ptr(channel_name_ptr, channel_name_len);
    let service_name_option: Option<String> =
        get_string_from_ptr(service_name_ptr, service_name_len);
    let message_option: Option<String> = get_string_from_ptr(message_ptr, message_len);

    if folder_option.is_none() {
        return;
    }
    if channel_name_option.is_none() || message_option.is_none() {
        return;
    }
    if logger_type == 1 && service_name_option.is_none() {
        return;
    }

    let folder: String = folder_option.unwrap();
    let channel_name: String = channel_name_option.unwrap();
    let message: String = message_option.unwrap();

    let manager: Arc<StrawberryLoggerManager> = StrawberryLoggerManager::instance();
    let cached_logger_option: Option<Arc<StrawberryLogger>> = manager.cached_logger(&channel_name);

    if cached_logger_option.is_none() {
        let logger_option: Option<Arc<StrawberryLogger>> =
            StrawberryLoggerFactory::create_default(folder, channel_name.clone());
        if logger_option.is_none() {
            return;
        }
    }
    if cached_logger_option.is_none() {
        return;
    }
    let logger: Arc<StrawberryLogger> = cached_logger_option.unwrap();

    let log_level: LogLevels = parse_log_level(&level);

    match logger_type {
        0 => {
            logger.log(&log_level, &message);
        }
        1 => {
            if service_name_option.is_none() {
                return;
            }
            let service_name: String = service_name_option.unwrap();

            let service_logger_option: Option<Arc<StrawberryServiceLogger>> =
                logger.open_service(&service_name);
            if service_logger_option.is_none() {
                return;
            }

            let service_logger: Arc<StrawberryServiceLogger> = service_logger_option.unwrap();
            service_logger.log(&log_level, &message);
        }
        _ => {}
    }
}
