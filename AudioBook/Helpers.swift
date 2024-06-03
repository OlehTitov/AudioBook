//
//  Helpers.swift
//  AudioBook
//
//  Created by Oleh Titov on 29.05.2024.
//

import Foundation
import UIKit

let dateComponentsFormatter: DateComponentsFormatter = {
  let formatter = DateComponentsFormatter()
  formatter.allowedUnits = [.minute, .second]
  formatter.zeroFormattingBehavior = .pad
  return formatter
}()

enum AppIconProvider {
    static func appIcon(in bundle: Bundle = .main) -> UIImage {
        guard let icons = bundle.object(forInfoDictionaryKey: "CFBundleIcons") as? [String: Any],
              let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],
              let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String],
              let iconFileName = iconFiles.last,
              let icon = UIImage(named: iconFileName) else {
            fatalError("Could not find icons in bundle")
        }

        return icon
    }
}
