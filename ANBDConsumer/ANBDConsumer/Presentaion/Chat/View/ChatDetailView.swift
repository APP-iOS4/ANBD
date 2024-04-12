//
//  ChatDetailView.swift
//  ANBDConsumer
//
//  Created by 최정인 on 4/6/24.
//

import SwiftUI
import PhotosUI
import ANBDModel

struct ChatDetailView: View {
    /// 사용자 관련 변수 (추후 UserViewModel 연결 후 삭제)
    var myUserID: String = "likelion123"
    var userNickname: String = "죠니"
    
    /// 메시지 관련 변수 (추후 ChatViewModel 연결 후 삭제)
    @State private var message: String = ""
    @State private var selectedImage: [PhotosPickerItem] = []
    @State private var messages: [Message] = [
        Message(userID: "likelion123", userNickname: "줄이", createdAt: Calendar.current.date(byAdding: .day, value: -7, to: .now) ?? .now, content: "7일전메시지내가보냄"),
        Message(userID: "ltsnotme", userNickname: "죠니", createdAt: Calendar.current.date(byAdding: .day, value: -7, to: .now) ?? .now, content: "7일전메시지친구가가가가가가가가보냄7일전메시지친구가가가가가가가가보냄7일전메시지친구가가가가가가가가보냄7일전메시지친구가가가가가가가가보냄7일전메시지친구가가가가가가가가보냄7일전메시지친구가가가가가가가가보냄7일전메시지친구가가가가가가가가보냄7일전메시지친구가가가가가가가가보냄7일전메시지친구가가가가가가가가보냄"),
        Message(userID: "ltsnotme", userNickname: "죠니", createdAt: Calendar.current.date(byAdding: .day, value: -6, to: .now) ?? .now, content: "짜자자잔6일전메시지내가안보냄"),
        Message(userID: "ltsnotme", userNickname: "죠니", createdAt: Calendar.current.date(byAdding: .day, value: -6, to: .now) ?? .now, content: "짜자자잔"),
        Message(userID: "likelion123", userNickname: "줄이", createdAt: Calendar.current.date(byAdding: .day, value: -6, to: .now) ?? .now, content: "짜자자잔이거는 6일전 내가보냄"),
        Message(userID: "ltsnotme", userNickname: "죠니", createdAt: Calendar.current.date(byAdding: .day, value: -5, to: .now) ?? .now, content: "5일전 내가 안보냄"),
        Message(userID: "ltsnotme", userNickname: "죠니", createdAt: Calendar.current.date(byAdding: .day, value: -3, to: .now) ?? .now, content: "3일전 내가 안보냄내가내가내가 안보냈어"),
        Message(userID: "ltsnotme", userNickname: "죠니", createdAt: Calendar.current.date(byAdding: .day, value: -3, to: .now) ?? .now, content: "내가내낙나내나나는 아니ㅑ야"),
        Message(userID: "ltsnotme", userNickname: "죠니", createdAt: .now, content: "오늘 나 아님"),
        Message(userID: "ltsnotme", userNickname: "죠니", createdAt: .now, content: "오늘 나 아님222"),
        Message(userID: "ltsnotme", userNickname: "죠니", createdAt: .now, image: "DummyImage1"),
        Message(userID: "likelion123", userNickname: "줄이", createdAt: .now, content: "오늘 내가 보냄"),
        Message(userID: "likelion123", userNickname: "줄이", createdAt: .now, image: "DummyImage1"),]
    
    
    /// Sheet 관련 변수
    @State private var isShowingConfirmSheet: Bool = false
    @State private var isShowingCustomAlertView: Bool = false
    @State private var isShowingImageDetailView: Bool = false
    @State private var detailImage: String = "DummyPuppy3"
    @State private var isGoingToReportView: Bool = false
    @State private var isShowingStateChangeCustomAlert: Bool = false
    @Environment(\.dismiss) private var dismiss
    
    
    /// Product 관련 함수 (추후 삭제 ......)
    //@State private var isTrading: Bool = true
    @State private var tradeState: TradeState = .trading
    @State private var isDeleted: Bool = false
    
    var body: some View {
        ZStack {
            VStack {
                messageHeaderView
                    .padding(.vertical, 5)
                    .padding(.horizontal, 15)
                
                Divider()
                
                ScrollView {
                    ForEach(0..<messages.count, id: \.self) { i in
                        /// 날짜 구분선
                        if i == 0 || messages[i].dateStringWithYear != messages[i-1].dateStringWithYear {
                            MessageDateDividerView(dateString: messages[i].dateStringWithYear)
                                .padding()
                                .padding(.top, i == 0 ? 5 : 25)
                                .padding(.bottom, 25)
                        }
                        
                        /// 이미지 · 텍스트
                        MessageCell(message: messages[i])
                            .padding(.vertical, 1)
                            .padding(.horizontal, 20)
                    }
                }
                .defaultScrollAnchor(.bottom)
                
                messageSendView
                    .padding()
            }
            
            if isShowingStateChangeCustomAlert {
                CustomAlertView(isShowingCustomAlert: $isShowingStateChangeCustomAlert, viewType: .changeState) {
                    //task로 변경해주기~
                    if tradeState == .trading {
                        tradeState = .finish
                    } else {
                        tradeState = .trading
                    }
                }
            }
            
            if isShowingCustomAlertView {
                CustomAlertView(isShowingCustomAlert: $isShowingCustomAlertView, viewType: .leaveChatRoom) {
                    print("채팅방 나가기 ~~")
                    dismiss()
                }
            }
        }
        .onTapGesture {
            endTextEditing()
        }
        .navigationTitle(userNickname)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    isShowingConfirmSheet.toggle()
                }, label: {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 13))
                        .rotationEffect(.degrees(90))
                        .foregroundStyle(.gray900)
                })
            }
        }
        .confirmationDialog("", isPresented: $isShowingConfirmSheet) {
            Button("채팅 신고하기", role: .destructive) {
                isGoingToReportView.toggle()
            }
            
            Button("채팅방 나가기", role: .destructive) {
                isShowingCustomAlertView.toggle()
            }
        }
        .fullScreenCover(isPresented: $isShowingImageDetailView) {
            ImageDetailView(imageString: $detailImage, isShowingImageDetailView: $isShowingImageDetailView)
        }
        .navigationDestination(isPresented: $isGoingToReportView) {
            ReportView(reportViewType: .chat)
        }
        .onAppear {
            messages.sort(by: { $0.createdAt < $1.createdAt })
        }
    }
    
    // MARK: - 메시지 해더 뷰 (Trade 관련)
    private var messageHeaderView: some View {
        HStack {
            if isDeleted {
                Image(systemName: "exclamationmark.square.fill")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .padding(.trailing, 10)
                    .foregroundStyle(.gray500)
            } else {
                Image("DummyImage1")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 70, height: 70)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding(.trailing, 10)
            }
            
            VStack(alignment: .leading) {
                Text(isDeleted ? "삭제된 게시물" : "나 헤드셋 님 매직 키보드 플리증용용")
                    .lineLimit(1)
                    .font(ANBDFont.SubTitle3)
                
                Spacer()
                Text(isDeleted ? "글쓴이가 삭제한 게시물이에요. " : "헤드셋 ↔ 무선 키보드")
                    .foregroundStyle(.gray400)
                    .font(ANBDFont.Caption3)
            }
            .padding(.vertical, 8)
            
            Spacer()
            
            if !isDeleted {
                VStack(alignment: .leading) {
                    TradeStateChangeView(tradeState: $tradeState, isShowingCustomAlert: $isShowingStateChangeCustomAlert)
                    
                    Spacer()
                }
                .padding(.vertical, 5)
            }
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
            PhotosPicker(selection: $selectedImage, maxSelectionCount: 1, matching: .images) {
                Image(systemName: "photo.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 25)
                    .foregroundStyle(.gray400)
                    .padding(.horizontal, 5)
            }
            
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
                    message = ""
                }
            }, label: {
                Image(systemName: "paperplane.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28)
                    .foregroundStyle(message == "" ? .gray400 : .accentColor)
                    .rotationEffect(.degrees(43))
            })
            .disabled(message.isEmpty)
        }
    }
}

// MARK: - 메시지 Cell
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
                Button(action: {
                    detailImage = imageURL
                    isShowingImageDetailView.toggle()
                }, label: {
                    Image(imageURL)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 150)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                })
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
struct Message: Hashable, Identifiable {
    let id: String = UUID().uuidString
    
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
