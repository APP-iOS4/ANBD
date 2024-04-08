//
//  ItemCategory.swift
//
//
//  Created by 유지호 on 4/5/24.
//

import Foundation

public enum ItemCategory: String, Codable, CaseIterable {
    case digital
    case furnitureInterior
    case menClothingAccessories
    case womenClothingAccessories
    case beautyCosmetics
    case homeAppliances
    case sportsLeisure
    case homeKitchen
    case hobbiesGamesRecordsBooks
    case petSupplies
    case otherUsedItems
    
    public var labelText: String {
        switch self {
        case .digital:
            return "디지털 기기"
        case .furnitureInterior:
            return "가구/인테리어"
        case .menClothingAccessories:
            return "남성 의류/잡화"
        case .womenClothingAccessories:
            return "여성 의류/잡화"
        case .beautyCosmetics:
            return "뷰티/미용"
        case .homeAppliances:
            return "생활 가전"
        case .sportsLeisure:
            return "스포츠/레저"
        case .homeKitchen:
            return "생활/주방"
        case .hobbiesGamesRecordsBooks:
            return "취미/게임/음반/도서"
        case .petSupplies:
            return "반려동물 용품"
        case .otherUsedItems:
            return "기타 중고물품"
        }
    }
}
