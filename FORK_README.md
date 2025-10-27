# Fork Maintenance Guide

This is a fork of [toy/image_optim_pack](https://github.com/toy/image_optim_pack) with custom modifications.

## Custom Workers/Tools

### WebP Support (cwebp, dwebp)
**Added:** 2025-10-27
**Version:** libwebp 1.4.0
**Files:**
- `Makefile` - Added LIBWEBP_VER, download config, build targets (lines 19, 122, 207-208, 299-300, 542-545)
- `checksums.mk` - Added LIBWEBP_SHA256
- `README.markdown` - Added libwebp documentation
- `acknowledgements/libwebp.txt` - Added license file

**Build config:** Static linking with `--disable-shared --enable-static` for portability

---

## Other Custom Changes

### Linux Build Fixes
- **chrpath fix** (commit 6802e96) - Fixes dynamic library paths for jpegtran/cjpeg on Linux
- **mozjpeg support** (commit c2d8b50) - Linux x86_64 binaries with mozjpeg

---

## Syncing with Upstream

### Before Merging

```bash
# Fetch upstream changes
git fetch upstream

# Review what changed
git log HEAD..upstream/master --oneline

# Check for conflicts in custom files
git diff HEAD..upstream/master -- Makefile checksums.mk README.markdown
```

### Files That May Conflict

| File | Why | Keep |
|------|-----|------|
| `Makefile` | WebP build targets | WebP sections (lines 19, 122, 207-208, 299-300, 542-545) |
| `checksums.mk` | WebP checksum | `LIBWEBP_SHA256 := ...` line |
| `README.markdown` | WebP docs | libwebp section in binaries list |
| `acknowledgements/libwebp.txt` | WebP license | Entire file |

### After Merging

```bash
# Test custom tools still build
make clean
make cwebp dwebp

# Test everything
make test

# Verify versions
vendor/darwin-arm64/cwebp -version  # Should show: 1.4.0
vendor/darwin-arm64/dwebp -version  # Should show: 1.4.0
```

---

## Adding New Custom Workers

When adding new custom tools:

1. Update this file with tool name, version, and affected files
2. Add checksums to `checksums.mk`
3. Document in `README.markdown`
4. Add license to `acknowledgements/`
5. Test build on all platforms (darwin-arm64, darwin-x86_64, linux-x86_64)
