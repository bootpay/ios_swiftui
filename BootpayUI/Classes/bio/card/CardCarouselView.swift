//
//  CardCarouselView.swift
//  BootpayUI
//
//  Created by Taesup Yoon on 2021/11/03.
//



import SwiftUI

struct CardCarouselView: View {
    
    var UIState: UIStateModel
    
    var body: some View
    {
        let spacing:            CGFloat = 16
        let widthOfHiddenCards: CGFloat = 32    // UIScreen.main.bounds.width - 10
        let cardHeight:         CGFloat = 185 //279, 160, 210
        
        let items = [
            Card( id: 0, name: "KB국민", code: "56730390****8036", color: Color.yellow),
            Card( id: 1, name: "삼성", code: "5123410****8036", color: Color.blue),
            Card( id: 2, name: "하나", code: "41730390****8036", color: Color.green ),
            Card( id: 3, name: "신한", code: "12303620****8036", color: Color.pink )
        ]
        
        return  Canvas {
            Carousel( numberOfItems: CGFloat( items.count ), spacing: spacing, widthOfHiddenCards: widthOfHiddenCards ) {
                ForEach( items, id: \.self.id ) { item in
                    
                    Item( _id:                  Int(item.id),
                          spacing:              spacing,
                          widthOfHiddenCards:   widthOfHiddenCards,
                          cardHeight:           cardHeight )
                    {
                        VStack {
                            HStack {
                                Text("\(item.name)")
                                Spacer()
                            }
                            Spacer()
                            HStack {
                                Spacer()
                                Text("\(item.code)")
                            }
                        }.padding(EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20))
                        
                    }
                    .foregroundColor( Color.black )
                    .background( item.color )
                    .border(Color.gray)
                    .cornerRadius( 8 )
                    .shadow( color: Color( "shadow1" ), radius: 4, x: 0, y: 4 )
                    .transition( AnyTransition.slide )
                    .animation( .spring() )
                }
            }
            .environmentObject( self.UIState )
        }
    }
}



struct Card
{
    var id:     Int
    var name:   String = ""
    var code:   String = ""
    var color: Color = Color.white
}



public class UIStateModel: ObservableObject
{
    @Published var activeCard: Int      = 0
    @Published var screenDrag: Float    = 0.0
}



struct Carousel<Items : View> : View {
    let items: Items
    let numberOfItems: CGFloat //= 8
    let spacing: CGFloat //= 16
    let widthOfHiddenCards: CGFloat //= 32
    let totalSpacing: CGFloat
    let cardWidth: CGFloat
    
    @GestureState var isDetectingLongPress = false
    
    @EnvironmentObject var UIState: UIStateModel
    
    @inlinable public init(
    numberOfItems: CGFloat,
    spacing: CGFloat,
    widthOfHiddenCards: CGFloat,
    @ViewBuilder _ items: () -> Items) {
        
        self.items = items()
        self.numberOfItems = numberOfItems
        self.spacing = spacing
        self.widthOfHiddenCards = widthOfHiddenCards
        self.totalSpacing = (numberOfItems - 1) * spacing
        self.cardWidth = UIScreen.main.bounds.width - (widthOfHiddenCards*2) - (spacing*2) //279
        
    }
    
    var body: some View {
        
        let totalCanvasWidth: CGFloat = (cardWidth * numberOfItems) + totalSpacing
        let xOffsetToShift = (totalCanvasWidth - UIScreen.main.bounds.width) / 2
        let leftPadding = widthOfHiddenCards + spacing
        let totalMovement = cardWidth + spacing
        
        let activeOffset = xOffsetToShift + (leftPadding) - (totalMovement * CGFloat(UIState.activeCard))
        let nextOffset = xOffsetToShift + (leftPadding) - (totalMovement * CGFloat(UIState.activeCard) + 1)
        
        var calcOffset = Float(activeOffset)
        
        if (calcOffset != Float(nextOffset)) {
            calcOffset = Float(activeOffset) + UIState.screenDrag
        }
        
        return HStack(alignment: .center, spacing: spacing) {
            items
        }
        .offset(x: CGFloat(calcOffset), y: 0)
        .gesture(DragGesture().updating($isDetectingLongPress) { currentState, gestureState, transaction in
            self.UIState.screenDrag = Float(currentState.translation.width)
            
        }.onEnded { value in
            self.UIState.screenDrag = 0
            
            if (value.translation.width < -50 && self.UIState.activeCard < Int(numberOfItems) - 1) {
                self.UIState.activeCard = self.UIState.activeCard + 1
                let impactMed = UIImpactFeedbackGenerator(style: .medium)
                impactMed.impactOccurred()
            }
            
            if (value.translation.width > 50 && self.UIState.activeCard > 0) {
                self.UIState.activeCard = self.UIState.activeCard - 1
                let impactMed = UIImpactFeedbackGenerator(style: .medium)
                impactMed.impactOccurred()
            }
            
//            print(self.UIState.activeCard)
        })
    }
}



struct Canvas<Content : View> : View {
    let content: Content
    @EnvironmentObject var UIState: UIStateModel
    
    @inlinable init(@ViewBuilder _ content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .center)
            .background(Color.white.edgesIgnoringSafeArea(.all))
    }
}



struct Item<Content: View>: View {
    @EnvironmentObject var UIState: UIStateModel
    let cardWidth: CGFloat
    let cardHeight: CGFloat
    
    var _id: Int
    var content: Content
    
    @inlinable public init(
    _id: Int,
    spacing: CGFloat,
    widthOfHiddenCards: CGFloat,
    cardHeight: CGFloat,
    @ViewBuilder _ content: () -> Content
    ) {
        self.content = content()
        self.cardWidth = UIScreen.main.bounds.width - (widthOfHiddenCards*2) - (spacing*2) //279
        self.cardHeight = cardHeight
        self._id = _id
    }
    
    var body: some View {
        content
            .frame(width: cardWidth, height: _id == UIState.activeCard ? cardHeight : cardHeight - 60, alignment: .center)
    }
}

