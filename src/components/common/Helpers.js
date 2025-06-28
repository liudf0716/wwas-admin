export function timeStamp(second_time) {
    let time = `${parseInt(second_time)}秒`;
    if (parseInt(second_time) > 60) {
        const second = parseInt(second_time) % 60;
        const min = parseInt(second_time / 60);
        time = `${min}分${second}秒`;
        if (min > 60) {
            const hour = parseInt(min / 60);
            const remainingMin = min % 60;
            time = `${hour}小时${remainingMin}分${second}秒`;
            if (hour > 24) {
                const day = parseInt(hour / 24);
                const remainingHour = hour % 24;
                time = `${day}天${remainingHour}小时${remainingMin}分${second}秒`;
            }
        }
    }
    return time;
}

//毫秒数转为时间戳
export function dateForm(time) {
    const date = new Date(time * 1000);
    return date.toLocaleString();
}

// Check if the device is offline based on the given time
export function isOffline(time) {
    const now = new Date();
    const nowTime = now.getTime();
    if (nowTime - time > 60 * 2 * 1000) {
        return true;
    }
    return false;
}

// Convert bandwidth to a human-readable label
export function bandwidthLabel(by) {
    let kby = (by / 1024).toFixed(2);
    let uby = "KB";
    if (kby >= 1024) {
        uby = "MB";
        kby = (kby / 1024).toFixed(2);
    }
    if (kby >= 1024) {
        uby = "GB";
        kby = (kby / 1024).toFixed(2);
    }
    return `${kby} ${uby}`;
}

// Convert the number of bytes to a human-readable label
export function bytesLabel(by) {
    let kby = (by / 1024).toFixed(2);
    let uby = "MB";
    if (kby >= 1024) {
        uby = "GB";
        kby = (kby / 1024).toFixed(2);
    }
    return `${kby} ${uby}`;
}

// Convert the number of cpu usage to a human-readable label
export function cpuLabel(cpu) {
    return `${cpu}%`;
}

export function validateUrl(rule, value, callback) {
    const reg =
        /(http|https):\/\/[\w\-_]+(\.[\w\-_]+)+([\w\-\.,@?^=%&:/~\+#]*[\w\-\@?^=%&/~\+#])?/;
    console.log("value:", value);
    if (!reg.test(value)) {
        callback(new Error("请输入正确网址，如(https://baidu.com)"));
    } else {
        callback();
    }
}

export function validateNum(rule, value, callback) {
    const reg = /^\d+(\.\d+)?$/; //非负浮点数
    if (!reg.test(value)) {
        callback(new Error("输入必须是数字"));
    } else {
        callback();
    }
}

export function validateTimeNum(rule, value, callback) {
    const reg = /^\d+$/;
    if (!reg.test(value)) {
        callback(new Error("输入必须是数字"));
    } else {
        callback();
    }
}

export function validateSpace(rule, value, callback) {
    if (value.indexOf(" ") >= 0) {
        callback(new Error("输入有空格"));
    } else {
        callback();
    }
}

export function validateMac(rule, value, callback) {
    const reg_name =
        /^[A-Fa-f\d]{2}:[A-Fa-f\d]{2}:[A-Fa-f\d]{2}:[A-Fa-f\d]{2}:[A-Fa-f\d]{2}:[A-Fa-f\d]{2}$/;
    const reg_name2 =
        /^[A-Fa-f\d]{2}[A-Fa-f\d]{2}[A-Fa-f\d]{2}[A-Fa-f\d]{2}[A-Fa-f\d]{2}[A-Fa-f\d]{2}$/;
    const macarr = splitStr(value);
    const len = macarr.length;
    for (let i = 0; i < len; i++) {
        if (!reg_name.test(macarr[i]) && !reg_name2.test(macarr[i])) {
            callback(new Error("输入有误，以逗号或回车分隔"));
        } else {
            callback();
        }
    }
}

//按逗号和回车分隔字符串
export function splitStr(str) {
    const temp = str.split(/[\n,]/g);
    for (let i = 0; i < temp.length; i++) {
        if (temp[i] === "") {
            temp.splice(i, 1);
            //删除数组索引位置应保持不变
            i--;
        }
    }
    return temp;
}

export function validateAppId(rule, appId, callback) {
    const reg = /^wx[A-Fa-f\d]{16}$/;
    if (!reg.test(appId)) {
        callback(new Error("请输入正确的AppId"));
    } else {
        callback();
    }
}

export function formatMoney(value) {
    // the value is in cents, convert it to CNY
    return `${(value / 100).toFixed(2)}`;
}

export function convertMoney(value) {
    return value * 100;
}

export function search(baseUrl, uri, self) {
    if (self.search_word == "") {
        self.$message({ message: "输入不能为空", type: "warning" });
        return false;
    }

    self.loading = true;
    let deviceID = self.search_word;
    let params = {};
    params["device_id"] = deviceID;
    if (localStorage.getItem("userType") == 1) {
        //非超级管理员
        params["gw_channel"] = localStorage.getItem("ms_username");
    }
    self.$axios.post(baseUrl + uri, params).then(function (res) {
        self.loading = false;
        if (res.data.ret_code == "1001") {
            self.$message({ message: res.data.extra, type: "warning" });
            setTimeout(function () {
                self.$router.replace("login");
            }, 2000);
        }
        if (res.data.ret_code == 0) {
            self.listData = res.data.extra.result;
            self.pageTotal = res.data.extra.result.length;
        } else {
            self.$message({ message: res.data.extra, type: "warning" });
            self.listData = [];
            self.pageTotal = 0;
        }
    });
}

export function convertIp(num) {
    return [
        (num >>> 24) & 0xff,
        (num >>> 16) & 0xff,
        (num >>> 8) & 0xff,
        num & 0xff,
    ].join(".");
}
