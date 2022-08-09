const et = require('elementtree');
const path = require('path');
const fs = require('fs');

module.exports = function (context) {

    const ServiceEnum = Object.freeze({"ApplePay":"1", "GooglePay":"2"})
    const configFileName = 'www/json-config/PaymentsPluginConfiguration.json';

    var merchant_name = "";
    var merchant_country_code = "";
    var payment_allowed_networks = [];
    var payment_supported_capabilities = [];
    var payment_supported_card_countries = [];
    var shipping_supported_contacts = [];
    var billing_supported_contacts = [];
    var tokenization = "";
    var hasGooglePay = false;


    var projectRoot = context.opts.cordova.project ? context.opts.cordova.project.root : context.opts.projectRoot;

    var jsonConfig = "";
    try {
        jsonConfig = path.join(projectRoot, configFileName);
        var jsonConfigFile = fs.readFileSync(jsonConfig).toString();
        var jsonParsed = JSON.parse(jsonConfigFile);
    }
    catch {
        throw new Error("Missing configuration file or error trying to obtain the configuration.");
    }

    jsonParsed.app_configurations.forEach(function(configItem) {
        if (configItem.service_id == ServiceEnum.GooglePay) {
            hasGooglePay = true;
            var error_list = [];

            if(configItem.merchant_name && configItem.merchant_name !== ""){
                merchant_name = configItem.merchant_name;
            }
            else{
                error_list.push('Merchant Name');
            }

            if(configItem.merchant_country_code && configItem.merchant_country_code !== ""){
                merchant_country_code = configItem.merchant_country_code;
            }
            else{
                error_list.push('Merchant Country');
            }

            if(configItem.payment_allowed_networks && configItem.payment_allowed_networks.length > 0){
                payment_allowed_networks = configItem.payment_allowed_networks;
            }
            else{
                error_list.push('Payment Allowed Networks');
            }

            if(configItem.payment_supported_capabilities && configItem.payment_supported_capabilities.length > 0){
                payment_supported_capabilities = configItem.payment_supported_capabilities;
            }
            else{
                error_list.push('Payment Supported Capabilities');
            }

            if(configItem.payment_supported_card_countries && configItem.payment_supported_card_countries.length > 0){
                payment_supported_card_countries = configItem.payment_supported_card_countries;
            }

            if(configItem.shipping_supported_contacts && configItem.shipping_supported_contacts.length > 0){
                shipping_supported_contacts = configItem.shipping_supported_contacts;
            }

            if(configItem.billing_supported_contacts && configItem.billing_supported_contacts.length > 0){
                billing_supported_contacts = configItem.billing_supported_contacts;
            }

            if(configItem.tokenization){
                tokenization = JSON.stringify(configItem.tokenization);
            }
            else{
                error_list.push('PSP information');
            }

            if (error_list.length > 0) {
                throw new Error("The following fields are either missing or empty in the configuration: " + error_list);
            }
            return;
        }
    });

    if(hasGooglePay){
        var stringsXmlPath = path.join(projectRoot, 'platforms/android/app/src/main/res/values/strings.xml');
        var stringsXmlContents = fs.readFileSync(stringsXmlPath).toString();
        var etreeStrings = et.parse(stringsXmlContents);

        var merchantNameTags = etreeStrings.findall('./string[@name="merchant_name"]');
        for (var i = 0; i < merchantNameTags.length; i++) {
            merchantNameTags[i].text = merchant_name;
        }

        var merchantCountryTags = etreeStrings.findall('./string[@name="merchant_country_code"]');
        for (var i = 0; i < merchantCountryTags.length; i++) {
            merchantCountryTags[i].text = merchant_country_code;
        }

        var allowedNetworksTags = etreeStrings.findall('./string[@name="payment_allowed_networks"]');
        for (var i = 0; i < allowedNetworksTags.length; i++) {
            allowedNetworksTags[i].text = payment_allowed_networks;
        }

        var supportedCapabilitiesTags = etreeStrings.findall('./string[@name="payment_supported_capabilities"]');
        for (var i = 0; i < supportedCapabilitiesTags.length; i++) {
            supportedCapabilitiesTags[i].text = payment_supported_capabilities;
        }

        var supportedCardCountriesTags = etreeStrings.findall('./string[@name="payment_supported_card_countries"]');
        for (var i = 0; i < supportedCardCountriesTags.length; i++) {
            supportedCardCountriesTags[i].text = payment_supported_card_countries;
        }

        var shippingContactsTags = etreeStrings.findall('./string[@name="shipping_supported_contacts"]');
        for (var i = 0; i < shippingContactsTags.length; i++) {
            shippingContactsTags[i].text = shipping_supported_contacts;
        }

        var billingContactsTags = etreeStrings.findall('./string[@name="billing_supported_contacts"]');
        for (var i = 0; i < billingContactsTags.length; i++) {
            billingContactsTags[i].text = billing_supported_contacts;
        }

        var tokenizationTags = etreeStrings.findall('./string[@name="tokenization"]');
        for (var i = 0; i < tokenizationTags.length; i++) {
            tokenizationTags[i].text = tokenization;
        }
    
        var resultXmlStrings = etreeStrings.write();
        fs.writeFileSync(stringsXmlPath, resultXmlStrings);
    }

};