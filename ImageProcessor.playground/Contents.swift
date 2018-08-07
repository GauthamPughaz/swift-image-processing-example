import UIKit

var image = UIImage(named: "sample")!

/*
Usage of variables:
1. filterFactor: Used to increase or decrease the intensity of the filter.
2. filterPipeline: Used to store the filters in the user specified order.
*/

// Using enum for filter names instead of String for type safety.
enum Filters: String {
    case BrightnessFilter
    case ContrastFilter
    case RedFilter
    case BlueFilter
    case GreenFilter
}

// Binary operator overloaading for multiplication.
func *(lhs: Int, rhs: Double) -> Int {
    return Int(Double(lhs) * rhs)
}

// Filter parent class
class Filter {
    var averageRed: Int
    var averageGreen: Int
    var averageBlue: Int
    
    init() {
        averageRed = 0
        averageBlue = 0
        averageGreen = 0
    }
    
    // Calculates the average values of red, green, blue colors of the entire image pixel by pixel.
    func calculateAverage(rgbaImage: RGBAImage) {
        var totalRed = 0, totalGreen = 0, totalBlue = 0
        let totalCount = rgbaImage.height * rgbaImage.width
        
        for y in 0..<rgbaImage.height {
            for x in 0..<rgbaImage.width {
                let index = y * rgbaImage.width + x
                let pixel = rgbaImage.pixels[index]
                
                totalRed += Int(pixel.red)
                totalGreen += Int(pixel.green)
                totalBlue += Int(pixel.blue)
            }
        }
        
        averageRed = Int(totalRed / totalCount)
        averageGreen = Int(totalGreen / totalCount)
        averageBlue = Int(totalBlue / totalCount)
    }
    
    // Method to be overridden by child Filter classes.
    func applyFilter(filterFactor: Double, rgbaImage: RGBAImage) -> RGBAImage! {
        return nil
    }
}

// Increases or decreases the brightness in the image.
class BrightnessFilter: Filter {
    override init() {
        super.init()
    }
    
    override func applyFilter(filterFactor: Double, rgbaImage: RGBAImage) -> RGBAImage {
        var rgbaImage = rgbaImage
        calculateAverage(rgbaImage)
        for y in 0..<rgbaImage.height {
            for x in 0..<rgbaImage.width {
                let index = y * rgbaImage.width + x
                var pixel = rgbaImage.pixels[index]
                pixel.red = UInt8(max(0, min(255, Int(pixel.red) * filterFactor)))
                pixel.blue = UInt8(max(0, min(255, Int(pixel.blue) * filterFactor)))
                pixel.green = UInt8(max(0, min(255, Int(pixel.green) * filterFactor)))
                rgbaImage.pixels[index] = pixel
            }
        }
        return rgbaImage
    }
}

// Increases or decreases the contrast in the image.
class ContrastFilter: Filter {
    override init() {
        super.init()
    }
    
    override func applyFilter(filterFactor: Double, rgbaImage: RGBAImage) -> RGBAImage {
        var rgbaImage = rgbaImage
        calculateAverage(rgbaImage)
        for y in 0..<rgbaImage.height {
            for x in 0..<rgbaImage.width {
                let index = y * rgbaImage.width + x
                var pixel = rgbaImage.pixels[index]
                
                let blueDiff = Int(pixel.blue) - averageBlue
                let redDiff = Int(pixel.red) - averageRed
                let greenDiff = Int(pixel.green) - averageGreen
                
                pixel.blue = UInt8(max(0, min(255, averageBlue + blueDiff * filterFactor)))
                pixel.red = UInt8(max(0, min(255, averageRed + redDiff * filterFactor)))
                pixel.green = UInt8(max(0, min(255, averageGreen + greenDiff * filterFactor)))
                rgbaImage.pixels[index] = pixel
            }
        }
        return rgbaImage
    }
}

// Increases or decreases the red color in the image.
class RedFilter: Filter {
    override init() {
        super.init()
    }
    
    override func applyFilter(filterFactor: Double, rgbaImage: RGBAImage) -> RGBAImage {
        var rgbaImage = rgbaImage
        calculateAverage(rgbaImage)
        for y in 0..<rgbaImage.height {
            for x in 0..<rgbaImage.width {
                let index = y * rgbaImage.width + x
                var pixel = rgbaImage.pixels[index]
                
                let redDiff = Int(pixel.red) - averageRed
                
                if (redDiff > 0) {
                    pixel.red = UInt8(max(0, min(255, averageRed + redDiff * filterFactor)))
                    rgbaImage.pixels[index] = pixel
                }
            }
        }
        return rgbaImage
    }
}

// Increases or decreases the blue color in the image.
class BlueFilter: Filter {
    override init() {
        super.init()
    }
    
    override func applyFilter(filterFactor: Double, rgbaImage: RGBAImage) -> RGBAImage {
        var rgbaImage = rgbaImage
        calculateAverage(rgbaImage)
        for y in 0..<rgbaImage.height {
            for x in 0..<rgbaImage.width {
                let index = y * rgbaImage.width + x
                var pixel = rgbaImage.pixels[index]
                
                let blueDiff = Int(pixel.blue) - averageBlue
                
                if (blueDiff > 0) {
                    pixel.blue = UInt8(max(0, min(255, averageBlue + blueDiff * filterFactor)))
                    rgbaImage.pixels[index] = pixel
                }
            }
        }
        return rgbaImage
    }
}

// Increases or decreases the green color in the image.
class GreenFilter: Filter {
    override init() {
        super.init()
    }
    
    override func applyFilter(filterFactor: Double, rgbaImage: RGBAImage) -> RGBAImage {
        var rgbaImage = rgbaImage
        calculateAverage(rgbaImage)
        for y in 0..<rgbaImage.height {
            for x in 0..<rgbaImage.width {
                let index = y * rgbaImage.width + x
                var pixel = rgbaImage.pixels[index]
                
                let greenDiff = Int(pixel.green) - averageGreen
                
                if (greenDiff > 0) {
                    pixel.green = UInt8(max(0, min(255, averageGreen + greenDiff * filterFactor)))
                    rgbaImage.pixels[index] = pixel
                }
            }
        }
        return rgbaImage
    }
}

// Class which helps in processing the user specified image.
class ImageProcessor {
    var rgbaImage: RGBAImage
    var filterMap: NSDictionary
    
    init(image: UIImage) {
        rgbaImage = RGBAImage(image: image)!
        filterMap = [Filters.BrightnessFilter.rawValue: BrightnessFilter(),
                     Filters.ContrastFilter.rawValue: ContrastFilter(),
                     Filters.RedFilter.rawValue: RedFilter(),
                     Filters.GreenFilter.rawValue: GreenFilter(),
                     Filters.BlueFilter.rawValue: BlueFilter()]
    }
    
    // Calls the respective filter by its name along with the factor to apply.
    func applyFilter(filterName: Filters, filterFactor: Double) {
        let object = filterMap[filterName.rawValue] as! Filter
        rgbaImage = object.applyFilter(filterFactor, rgbaImage: rgbaImage)
        
    }
    
    // Applies all the filters along with their corresponding factors in the same order as specified in the pipelines.
    func applyFilters(filterPipeline: [Filters], factorPipeline: [Double]) {
        let count = filterPipeline.count
        if (count == factorPipeline.count) {
            for i in 0..<count {
                applyFilter(filterPipeline[i], filterFactor: factorPipeline[i])
            }
        } else {
            print("Piplelines must have same length")
        }
    }
    
    // Returns the filtered image.
    func getFilteredImage() -> UIImage {
        return rgbaImage.toUIImage()!
    }
}

// DEMO

// Applying individual filter.
let imageProcessor_1 = ImageProcessor(image: image)
imageProcessor_1.applyFilter(Filters.BrightnessFilter, filterFactor: 1.2)
imageProcessor_1.getFilteredImage()

// Applying pipelined filters
let imageProcessor_2 = ImageProcessor(image: image)
imageProcessor_2.applyFilters( [Filters.ContrastFilter,
                                Filters.GreenFilter,
                                Filters.BrightnessFilter,
                                Filters.RedFilter,
                                Filters.BlueFilter],
                                factorPipeline: [1.2, 1.2, 1.2, 1.2, 1.2] )
imageProcessor_2.getFilteredImage()




