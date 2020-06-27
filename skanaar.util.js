var skanaar = skanaar || {}

skanaar.sum = function sum(list, plucker){
    var transform = {
        'undefined': _.identity,
        'string': function (obj){ return obj[plucker] },
        'number': function (obj){ return obj[plucker] },
        'function': plucker
    }[typeof plucker]
    for(var i=0, summation=0, len=list.length; i<len; i++)
        summation += transform(list[i])
    return summation
}

skanaar.hasSubstring = function hasSubstring(haystack, needle){
    if (needle === '') return true
    if (!haystack) return false
    return haystack.indexOf(needle) !== -1
}

skanaar.format = function format(template /* variadic params */){
    var parts = Array.prototype.slice.call(arguments, 1)
    return _.flatten(_.zip(template.split('#'), parts)).join('')
}

skanaar.hexToRgb = function (hex) {
    var result = /^#?([a-f\d]{2})([a-f\d]{2})([a-f\d]{2})$/i.exec(hex);
    return result ? {
        r: parseInt(result[1], 16),
        g: parseInt(result[2], 16),
        b: parseInt(result[3], 16)
    } : null;
}

String.prototype.replaceAt=function(index, character) {
    return this.substr(0, index) + character + this.substr(index+character.length);
}

String.prototype.padLeft = function(n, str) {
    return Array(n-this.length+1).join(str||'0')+this;
}

Number.prototype.padLeft = function (n,str){
    return Array(n-String(this).length+1).join(str||'0')+this;
}