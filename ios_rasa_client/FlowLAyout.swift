////
////  FlowLAyout.swift
////  ios_rasa_client
////
////  Created by ayman moustafa on 11/04/2023.
////
//import SwiftUI
//struct FlowLayout: ViewModifier {
//    let hSpacing: CGFloat
//    let vSpacing: CGFloat
//
//    func body(content: Content) -> some View {
//        content
//            .background(GeometryReader { proxy in
//                Color.clear.preference(key: WidthPreferenceKey.self, value: proxy.size.width)
//            })
//            .onPreferenceChange(WidthPreferenceKey.self) { _ in }
//            .overlayPreferenceValue(WidthPreferenceKey.self) { width in
//                GeometryReader { proxy in
//                    VStack(alignment: .leading, spacing: vSpacing) {
//                        ForEach(content.children.indices) { index in
//                            HStack(spacing: hSpacing) {
//                                content.children[index]
//                                    .frame(width: UIDevice.current.orientation.isLandscape ? width * 0.3 : width * 0.5)
//                            }
//                            .frame(maxWidth: .infinity, alignment: .leading)
//                        }
//                    }
//                    .frame(width: width, height: proxy.size.height)
//                }
//            }
//    }
//}
//
//extension View {
//    func flowLayout(hSpacing: CGFloat = 8, vSpacing: CGFloat = 8) -> some View {
//        self.modifier(FlowLayout(hSpacing: hSpacing, vSpacing: vSpacing))
//    }
//}
