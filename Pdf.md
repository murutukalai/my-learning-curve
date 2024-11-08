use printpdf::*;
use image::io::Reader as ImageReader;
use std::io::BufWriter;
use std::fs::File;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    // Create a new PDF document with one page
    let (doc, page1, layer1) = PdfDocument::new("Image PDF", Mm(210.0), Mm(297.0), "Layer 1");
    let current_layer = doc.get_page(page1).get_layer(layer1);

    // Load first image
    let image1 = ImageReader::open("path_to_first_image.png")?.decode()?;
    let (img1_width, img1_height) = image1.dimensions();
    let image1 = Image::from_dynamic_image(&image1);

    // Load second image
    let image2 = ImageReader::open("path_to_second_image.png")?.decode()?;
    let (img2_width, img2_height) = image2.dimensions();
    let image2 = Image::from_dynamic_image(&image2);

    // Define the position for both images (Y-coordinates)
    let pos_x = Mm(50.0); // X position (same for both images)
    let pos_y_image1 = Mm(100.0); // Position for the first image (lower)
    let pos_y_image2 = Mm(150.0); // Position for the second image (above the first image)

    // Add first image to the page
    image1.add_to_layer(
        current_layer.clone(),
        Some(pos_x),
        Some(pos_y_image1),
        None,
        None,
        Some(Px(img1_width as usize)),
        Some(Px(img1_height as usize)),
        true,
        None,
    );

    // Add second image to the page, positioned above the first
    image2.add_to_layer(
        current_layer,
        Some(pos_x),
        Some(pos_y_image2),
        None,
        None,
        Some(Px(img2_width as usize)),
        Some(Px(img2_height as usize)),
        true,
        None,
    );

    // Save the PDF file
    let output = File::create("output.pdf")?;
    let mut buf_writer = BufWriter::new(output);
    doc.save(&mut buf_writer)?;

    Ok(())
}
