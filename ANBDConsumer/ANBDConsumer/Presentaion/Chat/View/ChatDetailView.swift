//
//  ChatDetailView.swift
//  ANBDConsumer
//
//  Created by 최정인 on 4/6/24.
//

import SwiftUI
import ANBDModel

struct ChatDetailView: View {
    /// 사용자 관련 변수
    var myUserID: String = "likelion123"
    var userNickname: String = "죠니"
    
    /// 메시지 관련 변수
    @State private var message: String = ""
    @State private var messages: [Message] = [Message(userID: "likelion123", userNickname: "줄이", createdAt: Calendar.current.date(byAdding: .day, value: -6, to: .now) ?? .now, content: "하이하이방가"),
                               Message(userID: "ltsnotme", userNickname: "죠니", createdAt: Calendar.current.date(byAdding: .day, value: -5, to: .now) ?? .now, content: "머요"),
                               Message(userID: "ltsnotme", userNickname: "죠니", createdAt: Calendar.current.date(byAdding: .day, value: -3, to: .now) ?? .now, content: "한"),
                               Message(userID: "ltsnotme", userNickname: "죠니", createdAt: Calendar.current.date(byAdding: .day, value: -3, to: .now) ?? .now, content: "글"),
                               Message(userID: "ltsnotme", userNickname: "죠니", createdAt: .now, content: "자"),
                               Message(userID: "ltsnotme", userNickname: "죠니", createdAt: .now, content: "테스트"),
                               Message(userID: "likelion123", userNickname: "줄이", createdAt: .now, image: "DummyImage1"),
                               Message(userID: "likelion123", userNickname: "줄이", createdAt: Calendar.current.date(byAdding: .day, value: -6, to: .now) ?? .now, content: "하이하이방가"),
                               Message(userID: "ltsnotme", userNickname: "죠니", createdAt: Calendar.current.date(byAdding: .day, value: -5, to: .now) ?? .now, content: "머요"),
                               Message(userID: "ltsnotme", userNickname: "죠니", createdAt: Calendar.current.date(byAdding: .day, value: -3, to: .now) ?? .now, content: "한"),
                               Message(userID: "ltsnotme", userNickname: "죠니", createdAt: Calendar.current.date(byAdding: .day, value: -3, to: .now) ?? .now, content: "글"),
                               Message(userID: "ltsnotme", userNickname: "죠니", createdAt: .now, content: "자"),
                               Message(userID: "ltsnotme", userNickname: "죠니", createdAt: .now, content: "테스트"),
                               Message(userID: "likelion123", userNickname: "줄이", createdAt: .now, image: "DummyImage1"),]
    
    
    /// Sheet 관련 변수
    @State private var isShowingConfirmSheet: Bool = false
    
    var body: some View {
        VStack {
            messageHeaderView
                .padding()
                .background(.white)
                
            ScrollView {
                ForEach(0..<messages.count) { i in
                    /// 날짜 구분선
                    if i == 0 || messages[i].dateStringWithYear != messages[i-1].dateStringWithYear {
                        MessageDateDividerView(dateString: messages[i].dateStringWithYear)
                            .padding()
                            .padding(.vertical, 10)
                    }
                    
                    MessageCell(message: messages[i])
                        .padding(.horizontal, 20)
                }
            }
            .padding(.vertical, 10)
            .background(.white)
            .defaultScrollAnchor(.bottom)
            
            messageSendView
                .padding()
                .background(.white)
        }
        .background(.gray50)
        .navigationTitle(userNickname)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    isShowingConfirmSheet.toggle()
                }, label: {
                    Image(systemName: "ellipsis")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 15)
                        .rotationEffect(.degrees(90))
                        .foregroundStyle(.gray900)
                })
            }
        }
        .confirmationDialog("", isPresented: $isShowingConfirmSheet) {
            Button("채팅 신고하기", role: .destructive) {
                // TODO: 채팅 신고하기
            }
            
            Button("채팅방 나가기", role: .destructive) {
                // TODO: 채팅방 나가기
            }
        }
        .onAppear {
            messages.sort(by: { $0.createdAt < $1.createdAt })
        }
    }
    
    // MARK: - 메시지 해더 뷰 (Trade 관련)
    private var messageHeaderView: some View {
        HStack {
            Image("DummyImage1")
                .resizable()
                .scaledToFill()
                .frame(width: 70, height: 70)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.trailing, 10)
            
            
            VStack(alignment: .leading) {
                Text("나 헤드셋 님 매직 키보드 플리증용용")
                    .lineLimit(1)
                    .font(ANBDFont.SubTitle3)
                
                Spacer()
                Text("헤드셋 ↔ 무선 키보드")
                    .foregroundStyle(.gray400)
                    .font(ANBDFont.Caption3)
            }
            .padding(.vertical, 8)
            
            Spacer()
            
            VStack(alignment: .leading) {
                Text("거래완")
                
                Spacer()
            }
            .padding(.vertical, 5)
        }
        .frame(height: 70)
        .foregroundStyle(.gray900)
    }
    
    @ViewBuilder
    private func MessageDateDividerView(dateString: String) -> some View {
        GeometryReader { geometry in
            HStack {
                Rectangle()
                    .fill(.gray400)
                    .frame(width: geometry.size.width / 3.5, height: 0.3)
                
                Spacer()
                
                Text(dateString)
                    .foregroundStyle(.gray400)
                    .font(ANBDFont.Caption1)
                
                Spacer()
                
                Rectangle()
                    .fill(.gray400)
                    .frame(width: geometry.size.width / 3.5, height: 0.3)
            }
        }
    }
    
    
    // MARK: - 메시지 전송 뷰
    private var messageSendView: some View {
        HStack {
            /// 사진 전송
            Button(action: {
                
            }, label: {
                Image(systemName: "photo.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25)
                    .foregroundStyle(.gray400)
                    .padding(.horizontal, 5)
            })
            
            /// 메시지 입력
            ZStack {
                Rectangle()
                    .fill(.gray50)
                    .clipShape(RoundedRectangle(cornerRadius: 30))
                
                TextField("메시지 보내기", text: $message)
                    .foregroundStyle(.gray900)
                    .font(ANBDFont.Caption3)
                    .padding(15)
            }
            .frame(height: 40)
            
            /// 메시지 전송
            Button(action: {
                if !message.isEmpty {
                    // TODO: 메시지 전송 액션
                }
            }, label: {
                Image(systemName: "paperplane.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28)
                    .foregroundStyle(message == "" ? .gray400 : .accentColor)
                    .rotationEffect(.degrees(43))
            })
        }
    }
}

// MARK: - 말풍선 Extension
extension ChatDetailView {
    @ViewBuilder
    private func MessageCell(message: Message) -> some View {
        let isMine: Bool = message.userID == myUserID
        
        HStack(alignment: .bottom) {
            if isMine {
                Spacer()
                
                Text("\(message.dateString)")
                    .foregroundStyle(.gray400)
                    .font(ANBDFont.Caption2)
            }
            
            // 텍스트
            if let content = message.content {
                Text(content)
                    .padding(15)
                    .foregroundStyle(isMine ? .white : .gray900)
                    .font(ANBDFont.Caption3)
                    .background(isMine ? Color.accentColor : .gray50)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
            }
            
            // 이미지
            if let imageURL = message.imageURL {
                Image(imageURL)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 150)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
            }
            
            if !isMine {
                Text("\(message.dateString)")
                    .foregroundStyle(.gray400)
                    .font(ANBDFont.Caption2)
                
                Spacer()
            }
        }
    }
}


#Preview {
    NavigationStack {
        ChatDetailView()
    }
}


// TODO: Message Struct -> ANBDModel에 추가시 삭제 예정
struct Message: Hashable {
    var id: String = UUID().uuidString
    
    let userID: String
    var userNickname: String
    
    var createdAt: Date = .now
    
    var content: String?
    var imageURL: String?
    
    var dateString : String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "a hh:mm"
        dateFormatter.locale = Locale(identifier:"ko_KR")
        return dateFormatter.string(from: createdAt)
    }
    
    var dateStringWithYear: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy년 MM월 dd일 (E)"
        dateFormatter.locale = Locale(identifier:"ko_KR")
        return dateFormatter.string(from: createdAt)
    }
    
    init(userID: String, userNickname: String, createdAt: Date, content: String? = nil, image: String? = nil) {
        self.userID = userID
        self.userNickname = userNickname
        self.createdAt = createdAt
        self.content = content
        self.imageURL = image
    }
}
