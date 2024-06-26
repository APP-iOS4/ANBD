//
//  ReportView.swift
//  ANBDConsumer
//
//  Created by 최정인 on 4/8/24.
//

import SwiftUI

struct ReportView: View {
    
    var reportViewType: ReportViewType = .article
    @State private var reportReason: String = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("\(reportTitle) 신고하기")
                .foregroundStyle(.gray900)
                .font(ANBDFont.SubTitle1)
            
            VStack(alignment: .trailing) {
                ZStack(alignment: .topLeading) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.clear)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(.gray400))
                        
                    
                    TextEditor(text: $reportReason)
                        .foregroundStyle(.gray900)
                        .padding(13)
                        
                    
                    if reportReason.isEmpty {
                        Text("신고 내용을 입력해주세요. (최대 200자)")
                            .padding()
                            .padding(.top, 5)
                    }
                }
                .frame(height: 200)
                .font(ANBDFont.body1)
                
                Text("\(reportReason.count)/200")
                    .padding(.horizontal, 5)
                    .font(ANBDFont.body2)
            }
            .foregroundStyle(.gray400)
            .padding(.vertical, 10)
            
            Spacer()
            
            Button(action: {
                
            }, label: {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(reportReason.isEmpty ? .gray200 : Color.accentColor)
                    
                    Text("신고하기")
                        .foregroundStyle(.white)
                }
            })
            .disabled(reportReason.isEmpty)
            .frame(height: 50)
        }
        .padding()
        .navigationTitle("신고하기")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
    }
}

extension ReportView {
    enum ReportViewType {
        case article, trade, chat, user
    }
    
    private var reportTitle: String {
        switch reportViewType {
        case .article:
            return "게시글"
        case .trade:
            return "게시물"
        case .chat:
            return "채팅"
        case .user:
            return "사용자"
        }
    }
}

#Preview {
    NavigationStack {
        ReportView()
    }
}
