var exec = require('cordova/exec');

exports.coolMethod = function (arg0, success, error) {
    exec(success, error, 'OSPayments', 'coolMethod', [arg0]);
};

exports.displaySetupButton = function(networks, success, error) {
    exec(success, error, 'OSPayments', 'displaySetupButton', [networks]);
}

exports.displayPayButton = function(success, error) {
    exec(success, error, 'OSPayments', 'displayPayButton');
}

exports.clickSetupButton = function(success, error) {
    exec(success, error, 'OSPayments', 'clickSetupButton');
}

exports.clickPayButton = function(success, error) {
    exec(success, error, 'OSPayments', 'clickPayButton');
}

exports.getTotal = function(success, error) {
    exec(success, error, 'OSPayments', 'getTotal');
}

exports.setTotal = function(total, success, error) {
    exec(success, error, 'OSPayments', 'setTotal', [total]);
}

exports.getMerchant = function(success, error) {
    exec(success, error, 'OSPayments', 'getMerchant');
}

exports.setMerchant = function(merchant, success, error) {
    exec(success, error, 'OSPayments', 'setMerchant', [merchant]);
}

exports.getBillingInformation = function(success, error) {
    exec(success, error, 'OSPayments', 'getBillingInformation');
}

exports.setBillingInformation = function(billingInformation, success, error) {
    exec(success, error, 'OSPayments', 'setBillingInformation', [billingInformation]);
}

exports.getShippingInformation = function(success, error) {
    exec(success, error, 'OSPayments', 'getShippingInformation');
}

exports.setShippingInformation = function(shippingInformation, success, error) {
    exec(success, error, 'OSPayments', 'setShippingInformation', [shippingInformation]);
}