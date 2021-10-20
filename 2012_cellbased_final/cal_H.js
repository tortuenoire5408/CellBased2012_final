var LH = {
    LH0: -1.9531250e-3,
    LH1: -3.9062500e-3,
    LH2: 7.8125000e-3,
    LH3: 2.3437500e-2,
    LH4: -4.6875000e-2,
    LH5: -7.8125000e-2,
    LH6: 1.5625000e-1,
    LH7: 5.0000000e-1,
    LH8: 5.0000000e-1,
    LH9: 1.5625000e-1,
    LH10: -7.8125000e-2,
    LH11: -4.6875000e-2,
    LH12: 2.3437500e-2,
    LH13: 7.8125000e-3,
    LH14: -3.9062500e-3,
    LH15: -1.9531250e-3,
};

var HH = {
    HH0: -1.9531250e-3,
    HH1: 3.9062500e-3,
    HH2: 7.8125000e-3,
    HH3: -2.3437500e-2,
    HH4: -4.6875000e-2,
    HH5: 7.8125000e-2,
    HH6: 1.5625000e-1,
    HH7: -5.0000000e-1,
    HH8: 5.0000000e-1,
    HH9: -1.5625000e-1,
    HH10: -7.8125000e-2,
    HH11: 4.6875000e-2,
    HH12: 2.3437500e-2,
    HH13: -7.8125000e-3,
    HH14: -3.9062500e-3,
    HH15: 1.9531250e-3,
};

process();

function process() {
    for(e = 0; e <= 15; e++) {
        LH["LH" + e] = cal_xs(LH["LH" + e]);
    }
    for(g = 0; g <= 15; g++) {
        HH["HH" + g] = cal_xs(HH["HH" + g]);
    }
    return console.log({
        LH,
        HH
    });
}

function cal_xs(x) {
    let s = "";
    let s_ = "";
    let n;
    if(x < 0) n = 0 - x;
    else n = x;
    for(i = 0; i <= 11; i++) {
        n *= 2;
        if(n >= 1) {
            s += "1";
            n -= 1;
        } else {
            s += "0";
        }
        if(i == 11) {
            if(String(x)[0] == "-") {
                s_ = "1111";
                for(j = 0; j <= 11; j++) {
                    if(s[j] == "0") s_ += "1";
                    else if(s[j] == "1") s_ += "0";
                    if(j == 11) return to_Hex(1, s_);
                }
            } else {
                s_ += "0000,"
                for(j = 0; j <= 11; j++) {
                    if(s[j] == "0") s_ += ((j + 1) % 4 == 0 && j !== 11) ? "0," : "0";
                    else if(s[j] == "1") s_ += ((j + 1) % 4 == 0 && j !== 11) ? "1," : "1";
                    if(j == 11) return to_Hex(0, s_);
                }
            }
        }
    }
}

function to_Hex(prefix, string) {
    let value = "16'h";
    if(prefix) {
        value += (parseInt(string, 2) + 1).toString("16").toUpperCase();
        return value;
    } else {
        const words = string.split(',');
        for(k = 0; k <= 3; k++) {
            switch(words[k]) {
                case "0000": value += "0"; break;
                case "0001": value += "1"; break;
                case "0010": value += "2"; break;
                case "0011": value += "3"; break;
                case "0100": value += "4"; break;
                case "0101": value += "5"; break;
                case "0110": value += "6"; break;
                case "0111": value += "7"; break;
                case "1000": value += "8"; break;
                case "1001": value += "9"; break;
                case "1010": value += "A"; break;
                case "1011": value += "B"; break;
                case "1100": value += "C"; break;
                case "1101": value += "D"; break;
                case "1110": value += "E"; break;
                case "1111": value += "F"; break;
            }
            if(k == 3) return value;
        }
    }
}