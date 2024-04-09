//
//  ItemCategory.swift
//
//
//  Created by 유지호 on 4/5/24.
//

import Foundation

public enum ItemCategory: String, Codable, CaseIterable {
    case digital = "디지털기기"
    case furnitureInterior = "가구/인테리어"
    case menClothingAccessories = "남성 의류/잡화"
    case womenClothingAccessories = "여성 의류/잡화"
    case beautyCosmetics = "뷰티/미용"
    case homeAppliances = "생활가전"
    case sportsLeisure = "스포츠/레저"
    case homeKitchen = "생활/주방"
    case hobbiesGamesRecordsBooks = "취미/게임/음반/도서"
    case petSupplies = "반려동물 용품"
    case otherUsedItems = "기타 중고물품"
}
