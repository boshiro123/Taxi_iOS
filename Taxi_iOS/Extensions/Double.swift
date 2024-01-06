//
//  Double.swift
//  Taxi_3
//
//  Created by shirokiy on 08/10/2023.
//

import Foundation

extension Double{
    private var currencyFormatter:NumberFormatter{
        let formatter = NumberFormatter()
//        formatter.numberStyle = .currency.
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 2
        return formatter
    }
    func toCurrency()->String{
        return currencyFormatter.string(for: self) ?? ""
    }
}
