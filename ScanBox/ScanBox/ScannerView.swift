//
//  ScannerView.swift
//  ScanBox
//
//  Created by Victor Augusto Toledo Lúcio Borghi on 10/06/26.
//

import SwiftUI
import AVFoundation
import Vision

struct ScannerView: UIViewControllerRepresentable {
    @Binding var scannedCode: String?
    
    func makeUIViewController(context: Context) -> ScannerViewController {
        let controller = ScannerViewController()
        controller.delegate = context.coordinator
        return controller
    }
    
    func updateUIViewController(_ uiViewController: ScannerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, ScannerViewDelegate {
        var parent: ScannerView
        init(_ parent: ScannerView) { self.parent = parent }
        
        func didFindCode(_ code: String) {
            print("CÓDIGO ESCANEADO: '\(code)'")  // ← aqui
            DispatchQueue.main.async { self.parent.scannedCode = code }
        }
    }
}

protocol ScannerViewDelegate: AnyObject {
    func didFindCode(_ code: String)
}

class ScannerViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    weak var delegate: ScannerViewDelegate?
    private var captureSession = AVCaptureSession()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
    }
    
    private func setupCamera() {
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        
        do { videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice) }
        catch { return }
        
        if (captureSession.canAddInput(videoInput)) { captureSession.addInput(videoInput) } else { return }
        
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        if (captureSession.canAddOutput(videoOutput)) { captureSession.addOutput(videoOutput) } else { return }
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = view.layer.bounds
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        
        DispatchQueue.global(qos: .background).async { self.captureSession.startRunning() }
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let request = VNDetectBarcodesRequest { request, error in
            guard let results = request.results as? [VNBarcodeObservation],
                  let firstCode = results.first?.payloadStringValue else { return }
            self.delegate?.didFindCode(firstCode)
        }
        
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
    }
}
