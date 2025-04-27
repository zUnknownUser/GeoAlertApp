//
//  ThemeManager.swift
//  GeoAlertApp
//
//  Created by Lucas Amorim on 25/04/25.
//

import Foundation
import SwiftUI

struct ThemeManager {
    static func background(for theme: AppTheme) -> LinearGradient {
        switch theme {
        case .claro:
            return LinearGradient(colors: [Color.white, Color(.systemGray6)], startPoint: .top, endPoint: .bottom)
        case .escuro:
            return LinearGradient(colors: [Color.black, Color.gray], startPoint: .top, endPoint: .bottom)
        case .neon:
            return LinearGradient(colors: [Color.purple, Color.blue], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .pastel:
            return LinearGradient(colors: [Color.pink.opacity(0.3), Color.blue.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }

    static func primaryText(for theme: AppTheme) -> Color {
        switch theme {
        case .claro, .pastel:
            return .black
        case .escuro, .neon:
            return .white
        }
    }

    static func cardBackground(for theme: AppTheme) -> Color {
        switch theme {
        case .claro, .pastel:
            return Color(.systemBackground)
        case .escuro:
            return Color(.systemGray5)
        case .neon:
            return Color.purple.opacity(0.2)
        }
    }
    
    
       static func secondaryText(for theme: AppTheme) -> Color {
           return primaryText(for: theme).opacity(0.7)
       }


    static func accentColor(for theme: AppTheme) -> Color {
        switch theme {
        case .claro:
            return .blue
        case .escuro:
            return .green
        case .neon:
            return .pink
        case .pastel:
            return .cyan
        }
    }
}
