const et = require('elementtree');
const path = require('path');
const fs = require('fs');

module.exports = function (context) {


    const ServiceEnum = Object.freeze({"ApplePay":"1", "GooglePay":"2"})
    const configFileName = 'www/json-config/PaymentsPluginConfiguration.json';

    var merchant_id = "";
    var merchant_name = "";
    var merchant_country_code = "";
    var payment_allowed_networks = [];
    var payment_supported_capabilities = [];
    var payment_supported_card_countries = [];
    var shipping_supported_contacts = [];
    var billing_supported_contacts = [];

    var projectRoot = context.opts.cordova.project ? context.opts.cordova.project.root : context.opts.projectRoot;

    //read json config file       www/jsonConfig/PaymentsPluginConfiguration.json
    var jsonConfig = "";
    try {
        jsonConfig = path.join(projectRoot, configFileName);
        var jsonConfigFile = fs.readFileSync(jsonConfig).toString();
        var jsonParsed = JSON.parse(jsonConfigFile);

        jsonParsed.app_configurations.forEach(function(configItem) {
            if (configItem.service_id == ServiceEnum.GooglePay) {
                merchant_name = configItem.merchant_name;
                merchant_country_code = configItem.merchant_country_code;
                payment_allowed_networks = configItem.payment_allowed_networks;
                payment_supported_capabilities = configItem.payment_supported_capabilities;
                payment_supported_card_countries = configItem.payment_supported_card_countries;
                shipping_supported_contacts = configItem.shipping_supported_contacts;
                billing_supported_contacts = configItem.billing_supported_contacts;
            }
        });

    } catch {
        throw new Error("Missing configuration file or error trying to obtain the configuration.");
    }

    var stringsXmlPath = path.join(projectRoot, 'platforms/android/app/src/main/res/values/strings.xml');
    var stringsXmlContents = fs.readFileSync(stringsXmlPath).toString();
    var etreeStrings = et.parse(stringsXmlContents);

    var merchantNameTags = etreeStrings.findall('./string[@name="merchant_name"]');
    for (var i = 0; i < merchantNameTags.length; i++) {
        var data = merchantNameTags[i];
        data.text = merchant_name;
    }

    var merchantCountryTags = etreeStrings.findall('./string[@name="merchant_country_code"]');
    for (var i = 0; i < merchantCountryTags.length; i++) {
        var data = merchantCountryTags[i];
        data.text = merchant_country_code;
    }

    var allowedNetworksTags = etreeStrings.findall('./string-array[@name="payment_allowed_networks"]');
    for (var i = 0; i < allowedNetworksTags.length; i++) {

        console.log("entrou nas allowed networks");

        var newText = "";
        for (var j = 0; j < payment_allowed_networks.length; j++) {
            console.log("entrou nos payment_allowed_networks");
            newText.concat("<item>");
            newText.concat(payment_allowed_networks[j]);
            newText.concat("</item>");
        }
        console.log("newText: " + newText);

        var data = allowedNetworksTags[i];
        data.text = newText;
    }
    
    var resultXmlStrings = etreeStrings.write();
    fs.writeFileSync(stringsXmlPath, resultXmlStrings);
    
};


