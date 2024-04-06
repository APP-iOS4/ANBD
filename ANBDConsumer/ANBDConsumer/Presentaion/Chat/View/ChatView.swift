//
//  ChatView.swift
//  ANBDConsumer
//
//  Created by 최주리 on 4/3/24.
//

import SwiftUI

struct ChatView: View {
        let chats: [[String]] = [["죠니", "운관님 정말 채팅 진짜 잘 만드셨어요 ㄷ..ㄷ", "4월 15일", "13"], ["웅광당관운관운관당근운관", "운관님 꼬옥 중간고사 보세요 ... 파이팅 파이팅 이건 길게 써서 테스트 해봐야지 메롱메롱 짱메롱", "12월 31일", "100"], ["줄이", "줄이줄이 주리는 줄이 줄 주리 도넛꾸워", "6월 1일", "3"], ["마루", "짧테", "3월 31일", "0"], ["짱표", "짱표는 3대 400", "9월 11일", "99"], ["호맨vs호빵맨", "호맨은 호맨 호빵맨 의존성 쩌러", "1월 1일", "0"], ["시미시미", "시미시미열시미짱시미 열시미 구웃", "7월 7일", "0"]]
    
    @State private var isShowingConfirmSheet: Bool = false
    var body: some View {
        VStack {
            if chats.isEmpty {
                Text("진행 중인 채팅방이 없습니다.")
                    .foregroundStyle(.gray400)
                    .font(ANBDFont.body1)
            } else {
                ScrollView {
                    LazyVStack {
                        ForEach(chats, id: \.self) { chat in
                            SwipeAction(isShowingConfirm: $isShowingConfirmSheet) {
                                NavigationLink(value: "\(chat[0])") {
                                    ChatListCell(userNickname: chat[0], lastMessage: chat[1], lastDate: chat[2], unreadMessageCount: Int(chat[3]) ?? 0)
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 3)
                                }
                            }
                        }
                    }
                }
                .confirmationDialog("", isPresented: $isShowingConfirmSheet) {
                    Button("채팅방 나가기", role: .destructive) {
                        // TODO: 채팅방 나가기
                    }
                } message: {
                    Text("해당 채팅방을 나가시겠습니까?")
                }
            }
        }
        .navigationTitle("채팅")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: String.self) { text in
            ChatDetailView(userNickname: text)
        }
    }
}

// MARK: - custom swipe action
struct SwipeAction<Content: View>: View {
    @Binding var isShowingConfirm: Bool
    @ViewBuilder var content: Content
    var viewID = UUID()
    var body: some View {
        ScrollViewReader { scrollProxy in
            ScrollView(.horizontal) {
                LazyHStack(spacing: 0) {
                    /// ChatListCell
                    content
                        .containerRelativeFrame(.horizontal)
                        .id(viewID)
                        .transition(.identity)
                    
                    /// Delete Button
                    Rectangle()
                        .fill(.clear)
                        .frame(width: 70)
                        .overlay(alignment: .trailing) {
                            Button(action: {
                                isShowingConfirm.toggle()
                                withAnimation(.snappy) {
                                    scrollProxy.scrollTo(viewID, anchor: .topLeading)
                                }
                            }, label: {
                                Image(systemName: "trash.fill")
                                    .font(.title3)
                                    .foregroundStyle(.white)
                                    .frame(width: 70)
                                    .frame(maxHeight: .infinity)
                            })
                            .buttonStyle(.plain)
                            .background(.heartRed)
                        }
                }
                .scrollTargetLayout()
                .visualEffect { content, geometryProxy in
                    content
                        .offset(x: scrollOffset(geometryProxy))
                }
            }
            .scrollIndicators(.hidden)
            .scrollTargetBehavior(.viewAligned)
            .background(.white)
        }
    }
    
    func scrollOffset(_ proxy: GeometryProxy) -> CGFloat {
        let minX = proxy.frame(in: .scrollView(axis: .horizontal)).minX
        return (minX > 0 ? -minX : 0)
    }
}

#Preview {
    NavigationStack {
        ChatView()
    }
}
