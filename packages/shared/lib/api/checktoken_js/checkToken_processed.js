const UPDATE_FUNC_TIMING = "UPDATE_FUNC_TIMING",
    UPDATE_TIME_OFFSET = "UPDATE_TIME_OFFSET",
    UPDATE_OPTIONS = "UPDATE_OPTIONS",
    base64table2 = ["q", "X", "N", "S", "C", "3", "W", "T", "6", "7", "d", "G", "u", "4", "I", "s", "r", "a", "K", "F", "n", "5", "0", "Q", "/", "f", "o", "t", "x", "y", "p", "A", "2", "O", "i", ".", "g", "m", "U", "+", "M", "b", "J", "j", "L", "k", "v", "Z", "Y", "R", "w", "8", "1", "e", "h", "9", "B", "V", "P", "H", "E", "z", "c", "D"],
    base64table = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "+", "/"]

function clamp2int8(value) {
    if (value < -128) return clamp2int8(128 - (-128 - value));
    if (value >= -128 && value <= 127) return value;
    if (value > 127) return clamp2int8(-129 + value - 127);
    throw Error("1001");
}

function int32toBytes(int32value) {
    const result = [];
    result[0] = clamp2int8(int32value >>> 24 & 255);
    result[1] = clamp2int8(int32value >>> 16 & 255);
    result[2] = clamp2int8(int32value >>> 8 & 255);
    result[3] = clamp2int8(int32value & 255);
    return result;
}

function copyArray(source, sourceStart, target, targetStart, length) {
    void 0 === source && (source = []);
    void 0 === target && (target = []);
    if (source.length) {
        if (source.length < length) throw Error("1003");
        for (let i = 0; i < length; i++) target[targetStart + i] = source[sourceStart + i];
    }
}

function byte2Hex(byte) {
    const characters = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f"];
    return "" + characters[byte >>> 4 & 15] + characters[byte & 15];
}

function bytes2hex(bytes) {
    void 0 ===
    bytes && (bytes = []);
    return bytes.map(function (byte) {
        return byte2Hex(byte);
    }).join("");
}

function string2hex(string) {
    const characters = "0123456789abcdef"
    let result = ""
    let code, idx
    for (idx = 0; idx < string.length; idx += 1) code = string.charCodeAt(idx), result += characters.charAt(code >>> 4 & 15) + characters.charAt(code & 15);
    return result;
}

function add32bit(num1, num2) {
    const lowSum = (num1 & 65535) + (num2 & 65535);
    return (num1 >> 16) + (num2 >> 16) + (lowSum >> 16) << 16 | lowSum & 65535;
}

function md5RoundOperation(logicRes, stateA, stateB, msgWord, shift, constant) {
    logicRes = add32bit(add32bit(stateA, logicRes), add32bit(msgWord, constant));
    return add32bit(logicRes << shift | logicRes >>> 32 - shift, stateB);
}

function md5FF(stateA, stateB, stateC, stateD, msgWord, shift, constant) {
    return md5RoundOperation(stateB & stateC | ~stateB & stateD, stateA, stateB, msgWord, shift, constant);
}

function md5GG(stateA, stateB, stateC, stateD, msgWord, shift, constant) {
    return md5RoundOperation(stateB & stateD | stateC & ~stateD, stateA, stateB, msgWord, shift, constant);
}

function md5HH(stateA, stateB, stateC, stateD, msgWord, shift, constant) {
    return md5RoundOperation(stateC ^ (stateB | ~stateD), stateA, stateB, msgWord, shift, constant);
}

function hex2bytes(hex) {
    void 0 === hex && (hex = "");
    hex = typeof hex === "string" ? hex : String(hex);

    let bytes = []
    let byteIdx = 0
    let charIdx = 0
    let count = hex.length / 2
    for (bytes, byteIdx, charIdx, count; byteIdx < count; byteIdx++) {
        const k = parseInt(hex.charAt(charIdx++), 16) << 4,
            m = parseInt(hex.charAt(charIdx++), 16);
        bytes[byteIdx] = clamp2int8(k + m);
    }
    return bytes;
}

function defaultBase64(bytes) {
    void 0 === bytes && (bytes = []);
    return base64(bytes, base64table, "=");
}

function base64EncodeChunk(bytes, start, count, table, padding) {
    void 0 === count && (count = 0);
    void 0 === table && (table = base64table2);
    void 0 === padding && (padding = "l");
    let thirdByte, encodedChunk = [];
    switch (count) {
        case 1:
            count = bytes[start];
            thirdByte = 0;
            encodedChunk.push(table[count >>> 2 & 63], table[(count << 4 & 48) + (thirdByte >>> 4 & 15)], padding, padding);
            break;
        case 2:
            count = bytes[start];
            thirdByte = bytes[start + 1];
            bytes = 0;
            encodedChunk.push(table[count >>> 2 & 63], table[(count << 4 & 48) + (thirdByte >>> 4 & 15)], table[(thirdByte << 2 & 60) + (bytes >>> 6 & 3)], padding);
            break;
        case 3:
            count = bytes[start];
            thirdByte = bytes[start + 1];
            bytes = bytes[start + 2];
            encodedChunk.push(table[count >>> 2 & 63], table[(count << 4 & 48) + (thirdByte >>> 4 & 15)],
                table[(thirdByte << 2 & 60) + (bytes >>> 6 & 3)], table[bytes & 63]);
            break;
        default:
            throw Error("1010");
    }
    return encodedChunk.join("");
}

function base64(bytes, table, padding) {
    void 0 === table && (table = []);
    void 0 === padding && (padding = "l");
    if (!bytes) return null;
    if (bytes.length === 0) return "";
    const chunkSize = 3;
    try {
        let encodedParts = []
        let byteIdx = 0

        for (encodedParts, byteIdx; byteIdx < bytes.length;)
            if (byteIdx + chunkSize <= bytes.length) encodedParts.push(base64EncodeChunk(bytes, byteIdx, chunkSize, table, padding)), byteIdx += chunkSize; else {
                encodedParts.push(base64EncodeChunk(bytes, byteIdx, bytes.length - byteIdx, table, padding));
                break;
            }
        return encodedParts.join("");
    } catch (m) {
        throw Error("1010");
    }
}

function md5hash(input) {
    let word,
        hashWords = [];
    hashWords[(input.length >> 2) - 1] = void 0;
    for (word = 0; word < hashWords.length; word += 1) hashWords[word] = 0;
    let bitLength = input.length * 8;
    for (word = 0; word < bitLength; word += 8) hashWords[word >> 5] |= (input.charCodeAt(word / 8) & 255) << word % 32;
    input = input.length * 8;
    hashWords[input >> 5] |= 128 << input % 32;
    hashWords[(input + 64 >>> 9 << 4) + 14] = input;
    let a0, b0, c0 = 1732584193,
        b = -271733879,
        c = -1732584194,
        d = 271733878;
    for (input = 0; input < hashWords.length; input += 16) word = c0, bitLength = b, a0 = c, b0 = d, c0 = md5FF(c0, b, c, d, hashWords[input], 7, -680876936), d = md5FF(d, c0, b, c, hashWords[input + 1], 12, -389564586), c = md5FF(c, d, c0, b, hashWords[input + 2], 17, 606105819), b = md5FF(b, c, d, c0, hashWords[input + 3], 22, -1044525330), c0 = md5FF(c0, b, c,
        d, hashWords[input + 4], 7, -176418897), d = md5FF(d, c0, b, c, hashWords[input + 5], 12, 1200080426), c = md5FF(c, d, c0, b, hashWords[input + 6], 17, -1473231341), b = md5FF(b, c, d, c0, hashWords[input + 7], 22, -45705983), c0 = md5FF(c0, b, c, d, hashWords[input + 8], 7, 1770035416), d = md5FF(d, c0, b, c, hashWords[input + 9], 12, -1958414417), c = md5FF(c, d, c0, b, hashWords[input + 10], 17, -42063), b = md5FF(b, c, d, c0, hashWords[input + 11], 22, -1990404162), c0 = md5FF(c0, b, c, d, hashWords[input + 12], 7, 1804603682), d = md5FF(d, c0, b, c, hashWords[input + 13], 12, -40341101), c = md5FF(c, d, c0, b, hashWords[input + 14], 17, -1502002290), b = md5FF(b, c, d, c0, hashWords[input + 15], 22, 1236535329), c0 = md5GG(c0, b, c, d, hashWords[input + 1], 5, -165796510), d = md5GG(d, c0, b, c, hashWords[input + 6], 9, -1069501632),
        c = md5GG(c, d, c0, b, hashWords[input + 11], 14, 643717713), b = md5GG(b, c, d, c0, hashWords[input], 20, -373897302), c0 = md5GG(c0, b, c, d, hashWords[input + 5], 5, -701558691), d = md5GG(d, c0, b, c, hashWords[input + 10], 9, 38016083), c = md5GG(c, d, c0, b, hashWords[input + 15], 14, -660478335), b = md5GG(b, c, d, c0, hashWords[input + 4], 20, -405537848), c0 = md5GG(c0, b, c, d, hashWords[input + 9], 5, 568446438), d = md5GG(d, c0, b, c, hashWords[input + 14], 9, -1019803690), c = md5GG(c, d, c0, b, hashWords[input + 3], 14, -187363961), b = md5GG(b, c, d, c0, hashWords[input + 8], 20, 1163531501), c0 = md5GG(c0, b, c, d, hashWords[input + 13], 5, -1444681467), d = md5GG(d, c0, b, c, hashWords[input + 2], 9, -51403784), c = md5GG(c, d, c0, b, hashWords[input + 7], 14, 1735328473), b = md5GG(b, c, d, c0, hashWords[input + 12], 20, -1926607734),
        c0 = md5RoundOperation(b ^ c ^ d, c0, b, hashWords[input + 5], 4, -378558), d = md5RoundOperation(c0 ^ b ^ c, d, c0, hashWords[input + 8], 11, -2022574463), c = md5RoundOperation(d ^ c0 ^ b, c, d, hashWords[input + 11], 16, 1839030562), b = md5RoundOperation(c ^ d ^ c0, b, c, hashWords[input + 14], 23, -35309556), c0 = md5RoundOperation(b ^ c ^ d, c0, b, hashWords[input + 1], 4, -1530992060), d = md5RoundOperation(c0 ^ b ^ c, d, c0, hashWords[input + 4], 11, 1272893353), c = md5RoundOperation(d ^ c0 ^ b, c, d, hashWords[input + 7], 16, -155497632), b = md5RoundOperation(c ^ d ^ c0, b, c, hashWords[input + 10], 23, -1094730640), c0 = md5RoundOperation(b ^ c ^ d, c0, b, hashWords[input + 13], 4, 681279174), d = md5RoundOperation(c0 ^ b ^ c, d, c0, hashWords[input], 11, -358537222), c = md5RoundOperation(d ^ c0 ^ b, c, d, hashWords[input + 3], 16, -722521979), b = md5RoundOperation(c ^ d ^ c0, b, c, hashWords[input + 6], 23, 76029189), c0 = md5RoundOperation(b ^ c ^ d, c0, b, hashWords[input + 9], 4, -640364487), d = md5RoundOperation(c0 ^ b ^
        c, d, c0, hashWords[input + 12], 11, -421815835), c = md5RoundOperation(d ^ c0 ^ b, c, d, hashWords[input + 15], 16, 530742520), b = md5RoundOperation(c ^ d ^ c0, b, c, hashWords[input + 2], 23, -995338651), c0 = md5HH(c0, b, c, d, hashWords[input], 6, -198630844), d = md5HH(d, c0, b, c, hashWords[input + 7], 10, 1126891415), c = md5HH(c, d, c0, b, hashWords[input + 14], 15, -1416354905), b = md5HH(b, c, d, c0, hashWords[input + 5], 21, -57434055), c0 = md5HH(c0, b, c, d, hashWords[input + 12], 6, 1700485571), d = md5HH(d, c0, b, c, hashWords[input + 3], 10, -1894986606), c = md5HH(c, d, c0, b, hashWords[input + 10], 15, -1051523), b = md5HH(b, c, d, c0, hashWords[input + 1], 21, -2054922799), c0 = md5HH(c0, b, c, d, hashWords[input + 8], 6, 1873313359), d = md5HH(d, c0, b, c, hashWords[input + 15], 10, -30611744), c = md5HH(c, d, c0, b, hashWords[input + 6], 15, -1560198380),
        b = md5HH(b, c, d, c0, hashWords[input + 13], 21, 1309151649), c0 = md5HH(c0, b, c, d, hashWords[input + 4], 6, -145523070), d = md5HH(d, c0, b, c, hashWords[input + 11], 10, -1120210379), c = md5HH(c, d, c0, b, hashWords[input + 2], 15, 718787259), b = md5HH(b, c, d, c0, hashWords[input + 9], 21, -343485551), c0 = add32bit(c0, word), b = add32bit(b, bitLength), c = add32bit(c, a0), d = add32bit(d, b0);
    hashWords = [c0, b, c, d];
    word = "";
    bitLength = hashWords.length * 32;
    for (input = 0; input < bitLength; input += 8) word += String.fromCharCode(hashWords[input >> 5] >>> input % 32 & 255);
    return word;
}

const updateHandlers = {};
updateHandlers[UPDATE_OPTIONS] = function (state, newOptions) {
    state.options = newOptions;
};
updateHandlers[UPDATE_FUNC_TIMING] = function (state, timingData) {
    state.$[timingData.cursor] = timingData.value || 0;
};
updateHandlers[UPDATE_TIME_OFFSET] = function (a, timeOffset) {
    a.Aa = timeOffset;
};

function extendObject(target, source) {
    for (const e in source) !source.hasOwnProperty(e) || (target[e] = source[e]);
    return target;
}

const storageCache = {};

function generateComponent() {
    const currentTime = new Date().getTime()
    const highBits = Math.floor(currentTime / 4294967296)
    const lowBits = currentTime % 4294967296
    let highBytes = int32toBytes(highBits)
    const lowBytes = int32toBytes(lowBits)
    let timeBytes = []

    copyArray(highBytes, 0, timeBytes, 0, 4);
    copyArray(lowBytes, 0, timeBytes, 4, 4);

    const randomBytes = []
    for (highBytes = 0; highBytes < 8; highBytes++) {
        randomBytes[highBytes] = clamp2int8(Math.floor(Math.random() * 256))
    }

    const result = []
    let byteIndex = 0
    for (result, byteIndex; byteIndex < timeBytes.length * 2; byteIndex++) {
        let idx
        if (byteIndex % 2 === 0) {
            idx = byteIndex / 2
        } else {
            idx = Math.floor(byteIndex / 2)
        }
        if (byteIndex % 2 === 0) {
            result[byteIndex] = result[byteIndex] | (randomBytes[idx] & 16) >>> 4 | (randomBytes[idx] & 32) >>> 3 | (randomBytes[idx] & 64) >>> 2 | (randomBytes[idx] & 128) >>> 1 | (timeBytes[idx] & 16) >>> 3 | (timeBytes[idx] & 32) >>> 2 | (timeBytes[idx] & 64) >>> 1 | (timeBytes[idx] & 128) >>> 0;
        } else {
            result[byteIndex] = result[byteIndex] | (randomBytes[idx] & 1) << 0 |
                (randomBytes[idx] & 2) << 1 | (randomBytes[idx] & 4) << 2 | (randomBytes[idx] & 8) << 3 | (randomBytes[idx] & 1) << 1 | (randomBytes[idx] & 2) << 2 | (randomBytes[idx] & 4) << 3 | (randomBytes[idx] & 8) << 4;
        }
        result[idx] = clamp2int8(result[idx]);
    }

    const resultHex = bytes2hex(result)
    const resultHex2 = string2hex(md5hash(decodeURIComponent(encodeURIComponent(resultHex + "dAWsBhCqtOaNLLJ25hBzWbqWXwiK99Wd"))))
    const finalResult = hex2bytes(resultHex2.substring(0, 16))
    return defaultBase64(finalResult.concat(result))
}

function hexPair2byte(hexPair) {
    if (null === hexPair || hexPair.length === 0) return [];
    hexPair = typeof hexPair === "string" ? hexPair : String(hexPair);

    let byteIdx = 0
    let charIdx = 0
    const bytes = [], count = hexPair.length / 2

    for (bytes, charIdx, byteIdx, count; byteIdx < count; byteIdx++) {
        const k = parseInt(hexPair.charAt(charIdx++), 16) << 4,
            m = parseInt(hexPair.charAt(charIdx++), 16);
        bytes[byteIdx] = clamp2int8(k + m);
    }
    return bytes;
}

function string2bytes(string) {
    if (null === string || void 0 === string) return string;
    string = encodeURIComponent(string);

    let charIdx = 0
    const bytes = [], length = string.length
    for (bytes, charIdx, length; charIdx < length; charIdx++)
        if (string.charAt(charIdx) === "%") {
            if (charIdx + 2 < length) bytes.push(hexPair2byte(string.charAt(++charIdx) + "" + string.charAt(++charIdx))[0]); else
                throw Error("1009");
        } else
            bytes.push(clamp2int8(string.charCodeAt(charIdx)));
    return bytes;
}

function encode(json) {
    if (!json) return "";
    const xorKey = [31, 125, -12, 60, 32, 48]
    let keyIdx = 0;

    json = string2bytes(json);

    const bytes = []
    let idx = 0

    for (bytes, idx; idx < json.length; idx++) bytes[idx] = clamp2int8(json[idx] ^ xorKey[keyIdx++ % xorKey.length]), bytes[idx] = clamp2int8(0 - bytes[idx]);
    return bytes2hex(bytes);
}

function StateManager(config) {
    this.state =
        config.state;
    this.listeners = [];
    const instance = this,
        originalHandle = this.handleEvent,
        originalUpdate = this.updateState;
    this.handleEvent = function (eventData, callback, options) {
        return originalHandle.call(instance, eventData, callback, options);
    };
    this.updateState = function (updateType, updateData) {
        return originalUpdate.call(instance, updateType, updateData);
    };
    this.mergeInitialState(config.initialState);
    this.mergeUpdateHandlers(config.updateHandlers);
}

StateManager.prototype.mergeUpdateHandlers = function (handlers) {
    this.updateHandlerMap = extendObject(this.updateHandlerMap || {}, handlers);
};
StateManager.prototype.mergeInitialState = function (stateProps) {
    this.initialProps = extendObject(this.initialProps || {}, stateProps);
};

const globalState = new StateManager({
    state: {
        options: {},
        Aa: 0,
        $: [0, 0, 0, 0, 0, 0]
    },
    initialState: {},
    updateHandlers: updateHandlers
});

function StorageManager(config) {
    void 0 === config && (config = {});
    this.delimiter = "__";
    this.cache = {};
    this.prefix = config.prefix || "";
}

StorageManager.prototype.prefixedKey = function (key) {
    return this.prefix ? this.prefix + ":" + key : key;
};

StorageManager.prototype.getValue = function (key) {
    key = this.prefixedKey(key);
    let cached = this.cache[key];
    if (!cached)
        try {
            cached = localStorage.getItem(key),
                this.cache[key] = cached;
        } catch (e) {
        }
    return cached ? cached.split(this.delimiter)[0] || "" : "";
};

function getStorageManager() {
    const productNum = globalState.state.options.merged ? globalState.state.options.productNumber : "";
    if (storageCache[productNum]) return storageCache[productNum];
    storageCache[productNum] = new StorageManager({
        prefix: productNum
    });
    return storageCache[productNum];
}

function entrypoint() {
    return encode(JSON["stringify"]({
        "r": 1,
        "d": getStorageManager().getValue("WM_DID"),
        "b": generateComponent()
    }));
}

console.log(entrypoint());