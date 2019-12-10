//
//  ColorClassification.swift
//  LightSmartLock
//
//  Created by mugua on 2019/11/19.
//  Copyright © 2019 mugua. All rights reserved.
//

import Foundation
import UIKit

enum ColorClassification {
    
    case navigationBackground
    case navigationItem
    case viewBackground
    case tableViewBackground
    case navigationTitle
    case textPrimary
    case textOpaque78
    case textDescription
    case textPlaceholder
    case lightBackground
    case primary
    case hudColor
    
    var value: UIColor {
        switch self {
        case .navigationBackground:
            if #available(iOS 13.0, *) {
                let color = UIColor { (collection) -> UIColor in
                    if collection.userInterfaceStyle == .dark {
                        return #colorLiteral(red: 0.2, green: 0.2039215686, blue: 0.2078431373, alpha: 1)
                    } else {
                        return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                    }
                }
                return color
            } else {
                return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            }
            
        case .navigationItem:
            if #available(iOS 13.0, *) {
                let color = UIColor { (collection) -> UIColor in
                    if collection.userInterfaceStyle == .dark {
                        return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                    } else {
                        return #colorLiteral(red: 0.09411764706, green: 0.1725490196, blue: 0.3098039216, alpha: 1)
                    }
                }
                return color
            } else {
                return #colorLiteral(red: 0.09411764706, green: 0.1725490196, blue: 0.3098039216, alpha: 1)
            }
            
        case .viewBackground:
            if #available(iOS 13.0, *) {
                let color = UIColor { (collection) -> UIColor in
                    if collection.userInterfaceStyle == .dark {
                        return #colorLiteral(red: 0.2, green: 0.2039215686, blue: 0.2078431373, alpha: 1)
                    } else {
                        return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                    }
                }
                return color
            } else {
                return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            }
            
        case .tableViewBackground:
            if #available(iOS 13.0, *) {
                let color = UIColor { (collection) -> UIColor in
                    if collection.userInterfaceStyle == .dark {
                        return #colorLiteral(red: 0.2, green: 0.2039215686, blue: 0.2078431373, alpha: 1)
                    } else {
                        return #colorLiteral(red: 0.9333333333, green: 0.9333333333, blue: 0.9333333333, alpha: 1)
                    }
                }
                return color
            } else {
                return #colorLiteral(red: 0.933242023, green: 0.9333798289, blue: 0.9332232475, alpha: 1)
            }
            
        case .navigationTitle:
            if #available(iOS 13.0, *) {
                let color = UIColor { (collection) -> UIColor in
                    if collection.userInterfaceStyle == .dark {
                        return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                    } else {
                        return #colorLiteral(red: 0.03921568627, green: 0.1215686275, blue: 0.2666666667, alpha: 1)
                    }
                }
                return color
            } else {
                return #colorLiteral(red: 0.03921568627, green: 0.1215686275, blue: 0.2666666667, alpha: 1)
            }
            
        case .textPrimary:
            if #available(iOS 13.0, *) {
                let color = UIColor { (collection) -> UIColor in
                    if collection.userInterfaceStyle == .dark {
                        return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
                    } else {
                        return #colorLiteral(red: 0.03921568627, green: 0.1215686275, blue: 0.2666666667, alpha: 1)
                    }
                }
                return color
            } else {
                return #colorLiteral(red: 0.03921568627, green: 0.1215686275, blue: 0.2666666667, alpha: 1)
            }
            
            
        case .textOpaque78:
            if #available(iOS 13.0, *) {
                let color = UIColor { (collection) -> UIColor in
                    if collection.userInterfaceStyle == .dark {
                        return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.78)
                    } else {
                        return #colorLiteral(red: 0.03921568627, green: 0.1215686275, blue: 0.2666666667, alpha: 0.78)
                    }
                }
                return color
            } else {
                return #colorLiteral(red: 0.03921568627, green: 0.1215686275, blue: 0.2666666667, alpha: 0.78)
            }
            
        case .textDescription:
            if #available(iOS 13.0, *) {
                let color = UIColor { (collection) -> UIColor in
                    if collection.userInterfaceStyle == .dark {
                        return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.6)
                    } else {
                        return #colorLiteral(red: 0.6509803922, green: 0.6823529412, blue: 0.737254902, alpha: 0.82)
                    }
                }
                return color
            } else {
                return #colorLiteral(red: 0.6509803922, green: 0.6823529412, blue: 0.737254902, alpha: 0.82)
            }
            
        case .textPlaceholder:
            if #available(iOS 13.0, *) {
                let color = UIColor { (collection) -> UIColor in
                    if collection.userInterfaceStyle == .dark {
                        return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.68)
                    } else {
                        return #colorLiteral(red: 0.6509803922, green: 0.6823529412, blue: 0.737254902, alpha: 0.68)
                    }
                }
                return color
            } else {
                return #colorLiteral(red: 0.6509803922, green: 0.6823529412, blue: 0.737254902, alpha: 0.68)
            }
            
        case .lightBackground:
            
            if #available(iOS 13.0, *) {
                let color = UIColor { (collection) -> UIColor in
                    if collection.userInterfaceStyle == .dark {
                        return #colorLiteral(red: 0.02352941176, green: 0.1098039216, blue: 0.2470588235, alpha: 1)
                    } else {
                        return #colorLiteral(red: 0.9484282136, green: 0.9528589845, blue: 0.9701302648, alpha: 1)
                    }
                }
                return color
            } else {
                return #colorLiteral(red: 0.9484282136, green: 0.9528589845, blue: 0.9701302648, alpha: 1)
            }
            
            
        case .primary:
            
            if #available(iOS 13.0, *) {
                let color = UIColor { (collection) -> UIColor in
                    if collection.userInterfaceStyle == .dark {
                        return #colorLiteral(red: 1, green: 0.6784313725, blue: 0.05490196078, alpha: 1)
                    } else {
                        return #colorLiteral(red: 1, green: 0.6784313725, blue: 0.05490196078, alpha: 1)
                    }
                }
                return color
            } else {
                return #colorLiteral(red: 0.9982913136, green: 0.6771650314, blue: 0.05553042889, alpha: 1)
            }
            
        case .hudColor:
            if #available(iOS 13.0, *) {
                let color = UIColor { (collection) -> UIColor in
                    if collection.userInterfaceStyle == .dark {
                        return #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.6)
                    } else {
                        return #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.12)
                    }
                }
                return color
            } else {
                return #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.12)
            }
            
        }
    }
}
