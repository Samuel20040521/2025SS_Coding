import numpy as np
from PIL import Image


def rgb_to_ycbcr(img):
    """Convert an RGB image to YCbCr (ITU‑R BT.601) without using rgb2ycbcr.

    Parameters
    ----------
    img : ndarray, uint8, shape (H, W, 3)
        Input RGB image.

    Returns
    -------
    ycbcr : ndarray, float32, shape (H, W, 3)
        Continuous‑valued Y, Cb, Cr channels in the range [0, 255].
    """
    img = img.astype(np.float32)
    R, G, B = img[:,:,0], img[:,:,1], img[:,:,2]

    Y  =  0.299   * R + 0.587   * G + 0.114   * B
    Cb = -0.168736 * R - 0.331264 * G + 0.5     * B + 128
    Cr =  0.5      * R - 0.418688 * G - 0.081312 * B + 128
    return np.stack((Y, Cb, Cr), axis=-1)

def ycbcr_to_rgb(ycbcr):
    """Convert YCbCr back to RGB uint8."""
    Y  = ycbcr[:,:,0]
    Cb = ycbcr[:,:,1] - 128
    Cr = ycbcr[:,:,2] - 128

    R = Y + 1.402   * Cr
    G = Y - 0.344136 * Cb - 0.714136 * Cr
    B = Y + 1.772   * Cb
    rgb = np.stack((R, G, B), axis=-1)
    return np.clip(rgb, 0, 255).astype(np.uint8)

def subsample_420(channel):
    """4:2:0 subsample a single‑channel image by averaging every 2×2 block."""
    H, W = channel.shape
    assert H % 2 == 0 and W % 2 == 0, "Image dimensions must be even for 4:2:0"
    return channel.reshape(H//2, 2, W//2, 2).mean(axis=(1,3))

def upsample_420(channel_sub, target_shape):
    """Bilinearly upsample a subsampled chroma channel back to full resolution."""
    from PIL import Image
    H, W = target_shape
    img = Image.fromarray(channel_sub.astype(np.float32), mode='F')
    return np.asarray(img.resize((W, H), Image.BILINEAR), dtype=np.float32)

def C420(A):
    """Apply 4:2:0 chroma subsampling & reconstruction using bilinear interpolation.

    Parameters
    ----------
    A : ndarray, uint8, (H, W, 3)

    Returns
    -------
    B : ndarray, uint8, (H, W, 3)
    """
    H, W, _ = A.shape
    ycbcr = rgb_to_ycbcr(A)
    Y, Cb, Cr = ycbcr[:,:,0], ycbcr[:,:,1], ycbcr[:,:,2]

    Cb_sub = subsample_420(Cb)
    Cr_sub = subsample_420(Cr)

    Cb_up = upsample_420(Cb_sub, (H, W))
    Cr_up = upsample_420(Cr_sub, (H, W))

    ycbcr_rec = np.stack((Y, Cb_up, Cr_up), axis=-1)
    return ycbcr_to_rgb(ycbcr_rec)

def psnr(A, B):
    """Compute PSNR between two uint8 RGB images."""
    mse = np.mean((A.astype(np.float32) - B.astype(np.float32)) ** 2)
    if mse == 0:
        return float('inf')
    return 20 * np.log10(255.0 / np.sqrt(mse))

if __name__ == "__main__":
    import argparse
    import os
    parser = argparse.ArgumentParser(description='4:2:0 image compression demo')
    parser.add_argument('input', help='path to input RGB image')
    parser.add_argument('output', nargs='?', default='reconstructed.png',
                        help='output path')
    args = parser.parse_args()

    img = np.asarray(Image.open(args.input).convert('RGB'))
    rec = C420(img)
    Image.fromarray(rec).save(args.output)
    print(f"PSNR: {psnr(img, rec):.2f} dB")
