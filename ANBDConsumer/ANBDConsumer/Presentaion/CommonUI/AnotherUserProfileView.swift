//
//  AnotherUserProfileView.swift
//  ANBDConsumer
//
//  Created by 김성민 on 4/8/24.
//

import SwiftUI

struct AnotherUserProfileView: View {
    @State private var isShowingReportDialog = false
    // MARK: 일단 하드 코딩. 이전 뷰에서 사용자에 대한 정보를 받아와야 함.
    
    var body: some View {
        VStack(spacing: 30) {
            HStack {
                Image("DefaultUserProfileImage")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 90, height: 90)
                    .clipShape(.circle)
                    .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("김몽글 님")
                        .foregroundStyle(Color.gray900)
                        .font(ANBDFont.pretendardBold(24))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("선호 지역 : 경남")
                        .foregroundStyle(Color.gray400)
                        .font(ANBDFont.Caption3)
                }
            }
            .padding()
            
            HStack(spacing: 12) {
                ActivityInformationComponent(title: "아껴 쓴 개수", count: 5)
                Divider()
                    .frame(height: 60)
                
                ActivityInformationComponent(title: "나눠 쓴 개수", count: 8)
                Divider()
                    .frame(height: 60)
                
                ActivityInformationComponent(title: "바꿔 쓴 개수", count: 13)
                Divider()
                    .frame(height: 60)
                
                ActivityInformationComponent(title: "다시 쓴 개수", count: 19)
            }
            
            Rectangle()
                .fill(Color.gray50)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
        }
        .navigationTitle("김몽글")
        .navigationBarTitleDisplayMode(.inline)
        
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    isShowingReportDialog.toggle()
                }, label: {
                    Image(systemName: "ellipsis")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 15)
                        .rotationEffect(.degrees(90))
                        .foregroundStyle(Color.gray900)
                })
            }
        }
        
        .confirmationDialog("신고하기", isPresented: $isShowingReportDialog) {
            Button("신고하기", role: .destructive) {
                // 신고하기 View
            }
        }
    }
    
    @ViewBuilder
    private func ActivityInformationComponent(title: String, count: Int) -> some View {
        Button(action: {
            
        }, label: {
            VStack(alignment: .center, spacing: 5) {
                
                Text("\(title)")
                    .foregroundStyle(Color.gray500)
                    .font(ANBDFont.SubTitle3)
                
                Text("\(count)")
                    .font(ANBDFont.pretendardSemiBold(22))
            }
        })
    }
}

#Preview {
    NavigationStack {
        AnotherUserProfileView()
    }
}
