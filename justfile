set shell := ["bash", "-uc"]

default:
    @just --list

setup:
    sudo apt update
    sudo apt install -y build-essential clang cmake ninja-build pkg-config \
        libgtk-3-dev liblzma-dev \
        curl file git unzip xz-utils zip libglu1-mesa

get:
    flutter pub get

analyze:
    dart analyze lib test

format:
    dart format lib test

test:
    dart test test/unit

run platform="linux":
    flutter run -d {{platform}}

build target="linux":
    #!/usr/bin/env bash
    set -euo pipefail
    if [ "{{target}}" = "deb" ]; then
        just deb
    elif [ "{{target}}" = "apk" ]; then
        flutter build apk --release
        echo "APK: build/app/outputs/flutter-apk/app-release.apk"
    else
        flutter build {{target}}
    fi

deb:
    #!/usr/bin/env bash
    set -euo pipefail
    flutter build linux --release

    pkg="point-machine"
    appid="tech.hammerhead.point_machine"
    binary="point_machine"
    arch="amd64"
    version="$(grep '^version:' pubspec.yaml | sed 's/version: *//; s/+.*//')"
    bundle="build/linux/x64/release/bundle"
    root="build/deb/${pkg}_${version}"
    deb="build/deb/${pkg}_${version}_${arch}.deb"

    rm -rf build/deb
    mkdir -p "$root/DEBIAN" "$root/usr/lib/$pkg" "$root/usr/bin" \
        "$root/usr/share/applications" \
        "$root/usr/share/icons/hicolor/512x512/apps"

    cp -r "$bundle/." "$root/usr/lib/$pkg/"
    ln -sf "/usr/lib/$pkg/$binary" "$root/usr/bin/$pkg"
    cp assets/icon/orbit-1024.png \
        "$root/usr/share/icons/hicolor/512x512/apps/$appid.png"

    cat > "$root/usr/share/applications/$appid.desktop" <<EOF
    [Desktop Entry]
    Type=Application
    Name=Point Machine
    Comment=Serverless peer-to-peer file synchronizer
    Exec=/usr/bin/$pkg
    Icon=$appid
    Terminal=false
    Categories=Network;FileTransfer;Utility;
    EOF

    cat > "$root/DEBIAN/control" <<EOF
    Package: $pkg
    Version: $version
    Section: net
    Priority: optional
    Architecture: $arch
    Maintainer: Hammerhead Software <hammerhead.software@gmail.com>
    Installed-Size: $(du -sk "$root/usr" | cut -f1)
    Depends: libgtk-3-0, liblzma5
    Description: Serverless peer-to-peer file synchronizer
     Point Machine syncs files directly between your own devices with no
     server of ours anywhere, including for discovery.
    EOF

    fakeroot dpkg-deb --build "$root" "$deb"
    echo "Built $deb"

    sudo dpkg -i "$deb" || sudo apt-get install -f -y
    sudo update-desktop-database -q 2>/dev/null || true
    sudo gtk-update-icon-cache -q /usr/share/icons/hicolor 2>/dev/null || true
    echo "Installed $pkg $version"

clean:
    flutter clean
