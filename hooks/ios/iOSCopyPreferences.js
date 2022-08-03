const et = require('elementtree');
const path = require('path');
const fs = require('fs');
const plist = require('plist');
const { ConfigParser } = require('cordova-common');
const { Console } = require('console');

module.exports = function (context) {

    const ServiceEnum = Object.freeze({"ApplePay":"1", "GooglePay":"2"})
    var projectRoot = context.opts.cordova.project ? context.opts.cordova.project.root : context.opts.projectRoot;

    var merchant_id = "";
    var merchant_name = "";
    var merchant_country_code = "";
    var payment_allowed_networks = [];
    var payment_supported_capabilities = [];
    var payment_supported_card_countries = [];
    var shipping_supported_contacts = [];
    var billing_supported_contacts = [];

    var appNamePath = path.join(projectRoot, 'config.xml');
    var appNameParser = new ConfigParser(appNamePath);
    var appName = appNameParser.name();

    let platformPath = path.join(projectRoot, 'platforms/ios');

    //read json config file
    var jsonConfig = "";
    try {
        jsonConfig = path.join(platformPath, 'www/json-config/PaymentsPluginConfiguration.json');
        var jsonConfigFile = fs.readFileSync(jsonConfig, 'utf8');
        var jsonParsed = JSON.parse(jsonConfigFile);
    } catch {
        throw new Error("Missing configuration file or error trying to obtain the configuration.");
    }
    
    jsonParsed.app_configurations.forEach(function(configItem) {
        if (configItem.service_id == ServiceEnum.ApplePay) {
            var error_list = [];
            
            if (configItem.merchant_id != null && configItem.merchant_id !== "") {
                merchant_id = configItem.merchant_id;
            } else {
                error_list.push('Merchant Id');
            }

            if (configItem.merchant_name != null && configItem.merchant_name !== "") {
                merchant_name = configItem.merchant_name;
            } else {
                error_list.push('Merchant Name');
            }

            if (configItem.merchant_country_code != null && configItem.merchant_country_code !== "") {
                merchant_country_code = configItem.merchant_country_code;
            } else {
                error_list.push('Merchant Country');
            }

            if (configItem.payment_allowed_networks != null && configItem.payment_allowed_networks.length > 0) {
                payment_allowed_networks = configItem.payment_allowed_networks;
            } else {
                error_list.push('Payment Allowed Networks');
            }

            if (configItem.payment_supported_capabilities != null && configItem.payment_supported_capabilities.length > 0) {
                payment_supported_capabilities = configItem.payment_supported_capabilities;
            } else {
                error_list.push('Payment Supported Capabilities');
            }

            shipping_supported_contacts = configItem.shipping_supported_contacts;
            billing_supported_contacts = configItem.billing_supported_contacts;
            payment_supported_card_countries = configItem.payment_supported_card_countries;                    
        
            if (error_list.length > 0) {
                throw new Error("Configuration is missing the following fields: " + error_list);
            }

            return;
        }
    });
    

    //Change info.plist
    var infoPlistPath = path.join(platformPath, appName + '/'+ appName +'-info.plist');
    var infoPlistFile = fs.readFileSync(infoPlistPath, 'utf8');
    var infoPlist = plist.parse(infoPlistFile);

    infoPlist['ApplePayMerchantID'] = merchant_id;
    infoPlist['ApplePayMerchantName'] = merchant_name;
    infoPlist['ApplePayMerchantCountryCode'] = merchant_country_code;
    infoPlist['ApplePayPaymentAllowedNetworks'] = payment_allowed_networks;
    infoPlist['ApplePayPaymentSupportedCapabilities'] = payment_supported_capabilities;
    infoPlist['ApplePayPaymentSupportedCardCountries'] = payment_supported_card_countries;
    infoPlist['ApplePayShippingSupportedContacts'] = shipping_supported_contacts;
    infoPlist['ApplePayBillingSupportedContacts'] = billing_supported_contacts;

    fs.writeFileSync(infoPlistPath, plist.build(infoPlist, { indent: '\t' }));

    // Change Entitlements files
    var debugEntitlementsPath = path.join(platformPath, appName + '/'+ 'Entitlements-Debug.plist');
    var debugEntitlementsFile = fs.readFileSync(debugEntitlementsPath, 'utf8');
    var debugEntitlements = plist.parse(debugEntitlementsFile);

    debugEntitlements['com.apple.developer.in-app-payments'] = [merchant_id];

    fs.writeFileSync(debugEntitlementsPath, plist.build(debugEntitlements, { indent: '\t' }));

    var releaseEntitlementsPath = path.join(platformPath, appName + '/' + 'Entitlements-Release.plist');
    var releaseEntitlementsFile = fs.readFileSync(releaseEntitlementsPath, 'utf8');
    var releaseEntitlements = plist.parse(releaseEntitlementsFile);

    releaseEntitlements['com.apple.developer.in-app-payments'] = [merchant_id];

    fs.writeFileSync(releaseEntitlementsPath, plist.build(releaseEntitlements, { indent: '\t' }));
};
