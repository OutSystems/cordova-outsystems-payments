import PassKit

extension PaymentsTotal {
    var paymentAmount: NSDecimalNumber {
        return NSDecimalNumber(decimal: self.amount)
    }
    
    var paymentDiscount: NSDecimalNumber? {
        guard let discount = self.discount else { return nil }
        return NSDecimalNumber(decimal: discount)
    }
    
    var paymentSummaryItems: [PKPaymentSummaryItem] {
        var summaryItems = [PKPaymentSummaryItem(label: "Sub-Total", amount: self.paymentAmount)]
        var total = self.paymentAmount
        
        if let discountDecimal = self.paymentDiscount {
            summaryItems += [PKPaymentSummaryItem(label: "Discount", amount: discountDecimal)]
            total = total.subtracting(discountDecimal)
        }
        
        summaryItems += [PKPaymentSummaryItem(label: "Total", amount: total)]
        
        return summaryItems
    }
}

extension PaymentsMerchant {
    var merchantCapabilities: PKMerchantCapability {
        // TODO: check what to pass here
        return .capability3DS
    }
    
    var supportedNetworks: [PKPaymentNetwork] {
        return self.networks.map { PKPaymentNetwork($0) }
    }
}

extension PaymentsBilling {
    var contactFields: Set<PKContactField> {
        return Set(self.contacts.map { PKContactField(rawValue: $0) })
    }
}

extension PaymentsDeliveryMethod {
    var paymentAmount: NSDecimalNumber {
        return NSDecimalNumber(decimal: self.amount)
    }
    
    var shippingMethod: PKShippingMethod {
        let shippingMethod = PKShippingMethod(label: self.labelText, amount: self.paymentAmount)
        shippingMethod.detail = self.detailText
        shippingMethod.identifier = self.labelText
        
        if #available(iOS 15.0, *) {
            let calendar = Calendar.current
            // TODO: is this enough or can be something else?
            let dateComponents: Set<Calendar.Component> = Set([.calendar, .year, .month, .day])
            let startDateComponents = calendar.dateComponents(dateComponents, from: self.startDate)
            let endDateComponents = calendar.dateComponents(dateComponents, from: self.endDate)
            shippingMethod.dateComponentsRange = PKDateComponentsRange(start: startDateComponents, end: endDateComponents)
        }
        
        return shippingMethod
    }
}

extension PaymentsShipping {
    var shippingType: PKShippingType {
        return .shipping
    }
    
    var contactFields: Set<PKContactField> {
        return Set(self.contacts.map { PKContactField(rawValue: $0) })
    }
    
    var shippingMethods: [PKShippingMethod]? {
        return self.deliveryMethods?.map { $0.shippingMethod }
    }
    
    var selectedShippingMethod: PKShippingMethod? {
        return self.selectedDeliveryMethod?.shippingMethod
    }
    
//    var supportedCountries: Set<String>? {
//        guard let allowedCountries = allowedCountries else { return nil }
//        return Set(allowedCountries)
//    }
}
