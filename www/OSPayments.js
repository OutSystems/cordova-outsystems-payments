var exec = require('cordova/exec');

exports.setupConfiguration = function(success, error) {
    exec(success, error, 'OSPayments', 'setupConfiguration');
};

exports.checkWalletSetup = function(success, error) {
    exec(success, error, 'OSPayments', 'checkWalletSetup');
};