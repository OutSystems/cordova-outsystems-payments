var exec = require('cordova/exec');

exports.setupConfiguration = function(success, error) {
    exec(success, error, 'OSPayments', 'setupConfiguration');
};