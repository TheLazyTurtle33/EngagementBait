from PIL import Image
import sys

CHUNK_WIDTH = 71
CHUNK_HEIGHT = 95

def rearrange_image(input_path, output_path):
    img = Image.open(input_path)
    width, height = img.size

    # Validate width
    if width != CHUNK_WIDTH:
        raise ValueError(f"Image width must be {CHUNK_WIDTH}, got {width}")

    # Validate height divisibility
    if height % CHUNK_HEIGHT != 0:
        raise ValueError(
            f"Image height must be divisible by {CHUNK_HEIGHT}, got {height}"
        )

    num_chunks = height // CHUNK_HEIGHT

    # Create new image (chunks laid out horizontally)
    new_width = num_chunks * CHUNK_WIDTH
    new_height = CHUNK_HEIGHT
    new_img = Image.new(img.mode, (new_width, new_height))

    for i in range(num_chunks):
        top = i * CHUNK_HEIGHT
        bottom = top + CHUNK_HEIGHT

        chunk = img.crop((0, top, CHUNK_WIDTH, bottom))

        new_img.paste(chunk, (i * CHUNK_WIDTH, 0))

    new_img.save(output_path)
    print(f"Saved rearranged image to {output_path}")


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python rechunk.py input.png output.png")
        sys.exit(1)

    rearrange_image(sys.argv[1], sys.argv[2])