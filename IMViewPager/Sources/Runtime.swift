//
//  Runtime.swift
//  IMViewPager
//
//  Created by immortal on 2022/1/14
//

import Foundation

/// Runtime that provides support for the dynamic properties of the Objective-C language.
class Runtime<T> {
    
    /// Returns the value associated with a given object for a given property name.
    ///
    /// - Parameter object: The source object for the association.
    /// - Parameter propertyName: The property name for the association.
    static func getAssociatedObject(_ object: Any, property propertyName: String) -> T? {
        guard let key = propertyName.asAssociatedObjectKey() else { return nil }
        return objc_getAssociatedObject(object, key) as? T
    }
    
    /// Sets an associated value for a given object using a given property name and association policy.
    ///
    /// - Parameter object: The source object for the association.
    /// - Parameter propertyName: The property name for the association.
    /// - Parameter value: The value to associate with the key key for object. Pass nil to clear an existing association.
    /// - Parameter policy: The policy for the association.
    ///  For possible values, see objc_AssociationPolicy.
    static func setAssociatedObject(
        _ object: Any,
        property propertyName: String,
        value: T,
        policy: objc_AssociationPolicy = .OBJC_ASSOCIATION_RETAIN_NONATOMIC
    ) {
        guard let key = propertyName.asAssociatedObjectKey() else { return }
        objc_setAssociatedObject(object, key, value, policy)
    }
}

private extension String {
    
    func asAssociatedObjectKey() -> UnsafeRawPointer? {
        if let bundleID = Bundle.main.bundleIdentifier {
             return UnsafeRawPointer(bitPattern: "\(bundleID).\(lowercased())".hashValue)
        }
        return UnsafeRawPointer(bitPattern: "com.basekit.\(lowercased())".hashValue)
    }
}
