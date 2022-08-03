function inputParam(input){

    const param = [
        '', 0, false, '0x0000000000000000000000000000000000000000'
    ];

    if(typeof input == 'string' && input.match(/^0x/)){
        param[3] = input;
    }
    else
    if(typeof input == 'integer'){
        param[1] = input;
    }
    else
    if(typeof input == 'bool'){
        param[2] = input;
    }
    else
    if(typeof input == 'string'){
        param[0] = input;
    }

    return param;

}

module.exports = {
    inputParam
}