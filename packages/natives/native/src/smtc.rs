use flutter_rust_bridge::frb;
#[cfg(target_os = "windows")]
use windows::{
    core::HSTRING,
    Foundation::TypedEventHandler,
    Media::{
        MediaPlaybackStatus, MediaPlaybackType, Playback::MediaPlayer,
        SystemMediaTransportControls, SystemMediaTransportControlsButton,
        SystemMediaTransportControlsButtonPressedEventArgs,
    },
    Storage::{FileProperties::ThumbnailMode, StorageFile, Streams::RandomAccessStreamReference},
};

use crate::frb_generated::StreamSink;

pub struct SmtcFlutter {
    #[cfg(target_os = "windows")]
    _smtc: SystemMediaTransportControls,
    #[cfg(target_os = "windows")]
    _player: MediaPlayer,
}

pub enum SMTCControlEvent {
    Play,
    Pause,
    Previous,
    Next,
    Unknown,
}

pub enum SMTCState {
    Paused,
    Playing,
}

/// Apis for Flutter
impl SmtcFlutter {
    #[frb(sync)]
    pub fn new() -> Self {
        #[cfg(target_os = "windows")]
        return Self::_new().unwrap();
        #[cfg(not(target_os = "windows"))]
        return SmtcFlutter {};
    }

    #[frb(sync)]
    pub fn subscribe_to_control_events(&self, sink: StreamSink<i32>) {
        #[cfg(target_os = "windows")]
        self._smtc
            .ButtonPressed(&TypedEventHandler::<
                SystemMediaTransportControls,
                SystemMediaTransportControlsButtonPressedEventArgs,
            >::new(move |_, event| {
                let event = event.as_ref().unwrap().Button().unwrap();
                let event = match event {
                    SystemMediaTransportControlsButton::Play => 0,
                    SystemMediaTransportControlsButton::Pause => 1,
                    SystemMediaTransportControlsButton::Next => 2,
                    SystemMediaTransportControlsButton::Previous => 3,
                    _ => -1,
                };
                sink.add(event).unwrap();

                Ok(())
            }))
            .unwrap();
    }

    #[frb(sync)]
    pub fn update_state(&self, state: SMTCState) {
        #[cfg(target_os = "windows")]
        self._update_state(state).unwrap();
    }

    #[frb(sync)]
    pub fn update_display(
        &self,
        title: String,
        artist: String,
        album: String,
        path: Option<String>,
    ) {
        #[cfg(target_os = "windows")]
        self._update_display(
            HSTRING::from(title),
            HSTRING::from(artist),
            HSTRING::from(album),
            path.map(HSTRING::from),
        )
        .unwrap();
    }

    #[frb(sync)]
    pub fn close(self) {
        #[cfg(target_os = "windows")]
        self._player.Close().unwrap();
    }
}

#[cfg(target_os = "windows")]
impl SmtcFlutter {
    #[frb(ignore)]
    fn _init_controls(smtc: &SystemMediaTransportControls) -> Result<(), windows::core::Error> {
        // 下一首
        smtc.SetIsNextEnabled(true)?;
        // 暂停
        smtc.SetIsPauseEnabled(true)?;
        // 播放（恢复）
        smtc.SetIsPlayEnabled(true)?;
        // 上一首
        smtc.SetIsPreviousEnabled(true)?;

        Ok(())
    }

    #[frb(ignore)]
    fn _new() -> Result<Self, windows::core::Error> {
        let _player = MediaPlayer::new()?;
        _player.CommandManager()?.SetIsEnabled(false)?;

        let _smtc = _player.SystemMediaTransportControls()?;
        Self::_init_controls(&_smtc)?;

        Ok(Self { _smtc, _player })
    }

    #[frb(ignore)]
    fn _update_state(&self, state: SMTCState) -> Result<(), windows::core::Error> {
        let state = match state {
            SMTCState::Playing => MediaPlaybackStatus::Playing,
            SMTCState::Paused => MediaPlaybackStatus::Paused,
        };
        self._smtc.SetPlaybackStatus(state)?;

        Ok(())
    }

    #[frb(ignore)]
    fn _update_display(
        &self,
        title: HSTRING,
        artist: HSTRING,
        album: HSTRING,
        path: Option<HSTRING>,
    ) -> Result<(), windows::core::Error> {
        let updater = self._smtc.DisplayUpdater()?;
        updater.SetType(MediaPlaybackType::Music)?;

        let music_properties = updater.MusicProperties()?;
        music_properties.SetTitle(&title)?;
        music_properties.SetArtist(&artist)?;
        music_properties.SetAlbumTitle(&album)?;

        if let Some(path) = path {
            let file = StorageFile::GetFileFromPathAsync(&path)?.get()?;
            let thumbnail = file
                .GetThumbnailAsyncOverloadDefaultSizeDefaultOptions(ThumbnailMode::MusicView)?
                .get()?;
            updater.SetThumbnail(&RandomAccessStreamReference::CreateFromStream(&thumbnail)?)?;
        }

        updater.Update()?;

        if !(self._smtc.IsEnabled()?) {
            self._smtc.SetIsEnabled(true)?;
        }

        Ok(())
    }
}
