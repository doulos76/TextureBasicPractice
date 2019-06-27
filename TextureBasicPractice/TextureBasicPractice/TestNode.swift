//
//  TestNode.swift
//  TextureBasicPractice
//
//  Created by minhoi_goo on 27/06/2019.
//  Copyright © 2019 minhoi_goo. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class TestNode: ASDisplayNode {
  lazy var textNode: ASTextNode = {
    let node = ASTextNode()
    node.style.flexShrink = 1.0
    return node
  }()
  
  lazy var imageNode: ASImageNode = {
    let node = ASImageNode()
    node.image = UIImage(named: "test.jpg")
    node.isLayerBacked = true
    return node
  }()
  
  override init() {
    super.init()
    self.automaticallyManagesSubnodes = true
  }
  
  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    let imgLayout = ASRatioLayoutSpec(ratio: 0.5, child: imageNode)
    return ASOverlayLayoutSpec(child: imgLayout, overlay: textNode)
  }
  
  let longpressGesture = UILongPressGestureRecognizer()
  
  override func didLoad() {
    self.view.addGestureRecognizer(longpressGesture)
    longpressGesture.addTarget(self, action: #selector(todo))
  }
  
  @objc func todo() {
    print("To do")
  }
}

