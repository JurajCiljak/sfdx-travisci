({
    deepCopy: function(o) {
       var output, v, key;
       output = Array.isArray(o) ? [] : {};
       for (key in o) {
           v = o[key];
           output[key] = (typeof v === "object") ? this.deepCopy(v) : v;
       }
       return output;
    }
})