var AbstractReader = require("./abstract-reader");
var system         = require("../utils/system");

//=========================================================
// Reader of local files
//=========================================================

class LocalFileReader extends AbstractReader {

    constructor(path) {
        super();
        this.data = system.require("fs").readFileSync(path);
    }

    getLength() {
        return this.data.length;
    }

    getData(start, end) {
        return this.data.slice(start, end);
    }

}

module.exports = LocalFileReader;
