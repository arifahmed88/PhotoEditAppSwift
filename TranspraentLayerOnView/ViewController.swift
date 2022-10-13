//
//  ViewController.swift
//  TranspraentLayerOnView
//
//  Created by PosterMaker on 7/26/22.
//

import UIKit

enum FiltersName{
    case blur, pixellated, sephia, blackAndwhite
}

class ViewController: UIViewController {
    
    @IBOutlet weak var filterButton: UIButton!
    @IBOutlet weak var parentView: UIView!
    @IBOutlet weak var gestureView: UIView!
    @IBOutlet weak var topImageView: UIImageView!
    @IBOutlet weak var bottomImageView: UIImageView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var switchLabel: UILabel!
    @IBOutlet weak var switchButton: UISwitch!
    @IBOutlet weak var slider: UISlider!
    
    var initialCenter = CGPoint()
    let imageNameArray:[String] = ["image1","image2","image3","image4","image5"]
    var position = 0
    var alphaValue = 0.5
    var brushSize = 147.5
    
    //arif
    var maskLayer = CALayer()
    var renderer: UIGraphicsImageRenderer?
    var maskImage: UIImage?
    var blurView = UIVisualEffectView()
    
    var gestureStartPoint = CGPoint()
    var gestureLastPoint = CGPoint()
    
    var normalImage = UIImage(named: "image1")
    var filterAppliedImage = UIImage(named: "image1")
    var isSwitchOn = true
    var filterName:FiltersName = .pixellated
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switchLabel.text = "Brush"
//        pixlattedImage = pixlattedImageGenerate(image: normalImage ?? UIImage())
        filterAppliedImage = getFilterAppliedImage(image: normalImage ?? UIImage())
        topImageView.image = normalImage
        bottomImageView.image = filterAppliedImage
        
        nextButton.layer.cornerRadius = nextButton.bounds.size.height*0.5
        resetButton.layer.cornerRadius = resetButton.bounds.size.height*0.5
        
        gestureView.frame = topImageView.frame
        gestureAddOnGestureView(gestureView: gestureView)
        maskLayerPropertyInitialize(maskView: topImageView)
        slider.value = 0.5
    
        topImageView.layer.mask = maskLayer
        
//        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
//        blurView = UIVisualEffectView(effect: blurEffect)
//        blurView.center = CGPoint(x: view.bounds.size.width*0.5, y: view.bounds.size.height*0.5)
//        blurView.frame.size = CGSize(width: 200, height: 200)
//        blurView.alpha = 0.5
//        blurView.layer.cornerRadius = blurView.bounds.size.width*0.5
//        blurView.layer.masksToBounds = true
//        //view.addSubview(blurView)
//
//        let blurPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panBlurView(_:)))
//        blurPanGestureRecognizer.minimumNumberOfTouches = 1
//        blurPanGestureRecognizer.maximumNumberOfTouches = 1
//        blurPanGestureRecognizer.delegate = self
//
//        blurView.addGestureRecognizer(blurPanGestureRecognizer)
        
    }
    
    func getFilterAppliedImage(image:UIImage) -> UIImage {
        
        var newImage = UIImage()
        
        switch filterName{
            
        case .pixellated:
            newImage = pixlattedImageGenerate(image: image)
            
        case .blur:
            newImage = gaussianBluredImageGenerate(image: image)
            
        case .sephia:
            newImage = sepiaImageGenerate(image: image)
            
        case .blackAndwhite:
            
            newImage = blackAndWhiteImageGenerate(image: image)
            
        }
        
        return newImage
    }
    
    @IBAction func filterButtonAction(_ sender: Any) {
        
        let sepiaAction = UIAlertAction(title: "Sepia",style: .destructive) { [self] (action) in
            self.filterName = .sephia
            filterAppliedImage = self.getFilterAppliedImage(image: normalImage ?? UIImage())
            bottomImageView.image = filterAppliedImage
        }
        
        let blurAction = UIAlertAction(title: "Blur",style: .destructive) { [self] (action) in
            self.filterName = .blur
            filterAppliedImage = self.getFilterAppliedImage(image: normalImage ?? UIImage())
            bottomImageView.image = filterAppliedImage
        }
        
        let pixelatedAction = UIAlertAction(title: "Pixelated",style: .destructive) { [self] (action) in
            self.filterName = .pixellated
            filterAppliedImage = self.getFilterAppliedImage(image: normalImage ?? UIImage())
            bottomImageView.image = filterAppliedImage
        }
        
        let BlackAndWhiteAction = UIAlertAction(title: "Black&White",style: .destructive) { [self] (action) in
            self.filterName = .blackAndwhite
            filterAppliedImage = self.getFilterAppliedImage(image: normalImage ?? UIImage())
            bottomImageView.image = filterAppliedImage
        }
        

        
        let cancelAction = UIAlertAction(title: "Cancel",style: .cancel) { (action) in
            print("cancel")
        }
        
        let alert = UIAlertController(title: "Select Image Filter",message: "",preferredStyle: .actionSheet)
        alert.addAction(sepiaAction)
        alert.addAction(blurAction)
        alert.addAction(pixelatedAction)
        alert.addAction(BlackAndWhiteAction)
        alert.addAction(cancelAction)
        
        // On iPad, action sheets must be presented from a popover.
        //alert.popoverPresentationController?.barButtonItem = self.filterButton
        
        self.present(alert, animated: true)
        
        
    }
    
    
    @IBAction func SwitchAction(_ sender: UISwitch) {
        
        if sender.isOn{
            switchLabel.text = "Brush"
            isSwitchOn = true
            let value = Float(rangeConverter(value: Float(brushSize), oldMin: 5, oldMax: 300, newMin: 0, newMax: 100))
            slider.value = (value/100)
        }
        else{
            switchLabel.text = "Alpha"
            isSwitchOn = false
            slider.value = Float(alphaValue)
        }
        
    }
    
    
    @IBAction func sliderAction(_ sender: UISlider) {
        if isSwitchOn{
            brushSize = rangeConverter(value: (sender.value*100), oldMin: 0, oldMax: 100, newMin: 5, newMax: 300)
            //print("brushSize=\(brushSize)")
            let maskImage = maskImageGenerate(point: gestureLastPoint)
            maskLayer.contents = maskImage?.cgImage
            
        }
        else{
            alphaValue = CGFloat(sender.value)
            let maskImage = maskImageGenerate(point: gestureLastPoint)
            maskLayer.contents = maskImage?.cgImage
//            blurView.alpha = CGFloat(slider.value)
            
        }
    }
    
    @IBAction func resetButtonAction(_ sender: Any) {

        maskLayerPropertyInitialize(maskView: topImageView)
        slider.value = 0.0
        alphaValue = 0.0
        brushSize = rangeConverter(value: (0.0*100.0), oldMin: 0, oldMax: 100, newMin: 5, newMax: 300)

    }
    @IBAction func nextButtonAction(_ sender: Any) {
        
        nextButton.isEnabled = false
        //DispatchQueue.global(qos: .background).async {
            self.position = (self.position+1)%(self.imageNameArray.count)
            self.normalImage = UIImage(named: self.imageNameArray[self.position])
            self.filterAppliedImage = self.getFilterAppliedImage(image: self.normalImage ?? UIImage())
            
            //DispatchQueue.main.async { [self] in
                self.topImageView.image = self.normalImage
                self.bottomImageView.image = self.filterAppliedImage
            //}
            
        //}
        
        nextButton.isEnabled = true
        
    }
    
    func gestureAddOnGestureView(gestureView:UIView) {
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panPiece(_:)))
            panGestureRecognizer.minimumNumberOfTouches = 1
            panGestureRecognizer.maximumNumberOfTouches = 1
            panGestureRecognizer.delegate = self
            gestureView.addGestureRecognizer(panGestureRecognizer)
    }

    
    func maskLayerPropertyInitialize(maskView:UIImageView) {
        
        circleShape.frame = topImageView.bounds
        circleShape.strokeColor = CGColor(red: 252/255, green: 3/255, blue: 78/255, alpha: 1)
        circleShape.path = nil
        let clearColor:UIColor = .clear
        circleShape.fillColor = clearColor.cgColor
        circleShape.lineWidth = 3.0
        topImageView.layer.addSublayer(circleShape)
        
        let bounds = maskView.bounds
        maskLayer.frame = bounds
        renderer = UIGraphicsImageRenderer(size: bounds.size)
        maskLayer.frame = bounds
        guard let renderer = renderer else { return }
        let imagetemp = renderer.image { (ctx) in
            UIColor.black.setFill()
            ctx.fill( bounds, blendMode: .normal)
        }
        maskImage = imagetemp
        maskLayer.contents = maskImage?.cgImage
    }
    
    @objc func panBlurView(_ gestureRecognizer : UIPanGestureRecognizer) {
       guard gestureRecognizer.view != nil else {return}
       let piece = gestureRecognizer.view!
       
       let translation = gestureRecognizer.translation(in: piece.superview)
       if gestureRecognizer.state == .began {
          
          self.initialCenter = piece.center
       }
          
       if gestureRecognizer.state != .cancelled {
          let newCenter = CGPoint(x: initialCenter.x + translation.x, y: initialCenter.y + translation.y)
          piece.center = newCenter
       }
       else {
          
          piece.center = initialCenter
       }
    }
    
    
    @objc private func panPiece(_ gestureRecognizer : UIPanGestureRecognizer) {
        
        let translation = gestureRecognizer.translation(in: gestureView)
        
        if gestureRecognizer.state == .began {
            
        }
        if gestureRecognizer.state != .cancelled {
            
            let point = CGPoint(x: gestureStartPoint.x + translation.x, y: gestureStartPoint.y + translation.y)
            gestureLastPoint = point
            let maskImage = maskImageGenerate(point: point)

            maskLayer.contents = maskImage?.cgImage
            topImageView.layer.mask = maskLayer
            
        }
        else {
            
        }
        
    }
    
    let circleShape = CAShapeLayer()
    
    func maskImageGenerate(point:CGPoint) -> UIImage? {
        
        let mainPath = UIBezierPath(arcCenter: point, radius: brushSize*0.5, startAngle: CGFloat(0), endAngle: CGFloat(Double.pi * 2), clockwise: false)
        
        
        guard let maskView = topImageView else { return UIImage() }
        guard let renderer = renderer else { return UIImage()}
        
//        circleShape.frame = topImageView.bounds
        circleShape.path = mainPath.cgPath
//        circleShape.strokeColor = CGColor(red: 252/255, green: 3/255, blue: 78/255, alpha: 1)
//        let clearColor:UIColor = .clear
//        circleShape.fillColor = clearColor.cgColor
        
        view.layoutIfNeeded()
        

        let bounds = maskView.bounds
        let imagetemp = renderer.image { (context) in
            if let maskImage = maskImage {
                maskImage.draw(in: bounds)
                let color = UIColor.black.cgColor
                context.cgContext.setFillColor(color)
                let blendMode: CGBlendMode
                var alpha: CGFloat
                blendMode = .sourceIn
                alpha = alphaValue
                
                let path = mainPath
                path.close()
                path.fill(with: blendMode, alpha: alpha)

            }
        }

        return imagetemp
        
    }
    
    func rangeConverter(value:Float,oldMin:CGFloat,oldMax:CGFloat,newMin:CGFloat,newMax:CGFloat) -> CGFloat {
         
//        let OldValue = Int(value*100)
        let OldValue = Int(value)
        
        let OldMin = Int(oldMin)
        let OldMax = Int(oldMax)
        let NewMin = Int(newMin)
        let NewMax = Int(newMax)
        
        
        let NewValue = (((OldValue - OldMin) * (NewMax - NewMin)) / (OldMax - OldMin)) + NewMin
        return CGFloat(NewValue)
    }
    
    func ciImageToUIImage(ciImage:CIImage) -> UIImage {
        
        let context = CIContext()
        if let cgimg = context.createCGImage(ciImage, from: ciImage.extent) {
            let processedImage = UIImage(cgImage: cgimg)
            return processedImage
        }
        return UIImage()
    }
    
    
    func pixlattedImageGenerate(image:UIImage) -> UIImage {
        
        guard let currentCGImage = image.cgImage else { return UIImage() }
        let currentCIImage = CIImage(cgImage: currentCGImage)

        let filter = CIFilter(name: "CIPixellate")
        filter?.setValue(currentCIImage, forKey: kCIInputImageKey)
        filter?.setValue(100, forKey: kCIInputScaleKey)
        guard let outputImage = filter?.outputImage else { return UIImage() }
        
        return ciImageToUIImage(ciImage: outputImage)

    }
    
    
    func gaussianBluredImageGenerate(image:UIImage) -> UIImage {
        
        guard let currentCGImage = image.cgImage else { return UIImage() }
        let currentCIImage = CIImage(cgImage: currentCGImage)

        let filter = CIFilter(name: "CIGaussianBlur")
        filter?.setValue(currentCIImage, forKey: kCIInputImageKey)
        //filter?.setValue(100, forKey: kCIInputScaleKey)
        guard let outputImage = filter?.outputImage else { return UIImage() }
        
        return ciImageToUIImage(ciImage: outputImage)

    }
    
    func sepiaImageGenerate(image:UIImage) -> UIImage {
        
        guard let currentCGImage = image.cgImage else { return UIImage() }
        let currentCIImage = CIImage(cgImage: currentCGImage)

        let filter = CIFilter(name: "CISepiaTone")
        filter?.setValue(currentCIImage, forKey: kCIInputImageKey)
        filter?.setValue(2, forKey: kCIInputIntensityKey)
        
        guard let outputImage = filter?.outputImage else { return UIImage() }
        
        return ciImageToUIImage(ciImage: outputImage)

    }
    
    func blackAndWhiteImageGenerate(image:UIImage) -> UIImage {
        
        guard let currentCGImage = image.cgImage else { return UIImage() }
        let currentCIImage = CIImage(cgImage: currentCGImage)

        let filter = CIFilter(name: "CIColorMonochrome")
        filter?.setDefaults()
        filter?.setValue(currentCIImage, forKey: kCIInputImageKey)
        //filter?.setValue(inputColor, forKey: kCIInputColorKey)
        filter?.setValue(1.0, forKey: kCIInputIntensityKey)
        guard let outputImage = filter?.outputImage else { return UIImage() }
        
        return ciImageToUIImage(ciImage: outputImage)

    }
    
    
    
    
}




extension ViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        gestureStartPoint = touch.location(in: gestureView)
        return true
    }
    
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldBeRequiredToFailBy otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//       // Do not begin the pan until the tap fails.
//       if gestureRecognizer == self.tapGestureRecognizer &&
//              otherGestureRecognizer == self.panGestureRecognizer {
//          return true
//       }
//       return false
//    }
}
