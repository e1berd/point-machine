release type="patch":
    #!/usr/bin/env bash
    set -euo pipefail

    current="$(grep '^version:' pubspec.yaml | sed 's/version: *//')"
    semver="$(echo "$current" | sed 's/[-+].*//')"
    build="$(echo "$current" | sed -n 's/.*+//p')"
    build="${build:-1}"

    IFS='.' read -r major minor patch <<< "$semver"

    case "{{ type }}" in
      patch) patch=$((patch + 1)) ;;
      minor) minor=$((minor + 1)); patch=0 ;;
      major) major=$((major + 1)); minor=0; patch=0 ;;
      *) echo "error: unknown type '{{ type }}' — use patch, minor, or major" >&2; exit 1 ;;
    esac

    new_ver="${major}.${minor}.${patch}"
    new_build=$((build + 1))

    sed -i "s/^version: .*/version: ${new_ver}+${new_build}/" pubspec.yaml

    git add pubspec.yaml
    git commit -m "release: v${new_ver}"
    git tag "v${new_ver}"

    echo "Released v${new_ver} (build ${new_build})"

build target="linux":
    #!/usr/bin/env bash
    set -euo pipefail
    if [ "{{ target }}" = "deb" ]; then
      just deb
    elif [ "{{ target }}" = "apk" ]; then
      flutter build apk --release
      echo "APK: build/app/outputs/flutter-apk/app-release.apk"
    else
      flutter build {{ target }}
    fi

deb:
    #!/usr/bin/env bash
    set -euo pipefail
    flutter build linux --release

    pkg="mesh-market"
    appid="tech.hammerhead.mesh_market"
    binary="mesh_market"
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
    Name=Mesh Market
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
     Mesh Market syncs files directly between your own devices with no
     server of ours anywhere, including for discovery.
    EOF

    fakeroot dpkg-deb --build "$root" "$deb"
    echo "Built $deb"

dmg:
    #!/usr/bin/env bash
    set -euo pipefail
    flutter build macos --release

    app="$(find build/macos/Build/Products/Release -maxdepth 1 -name '*.app' | head -1)"
    version="$(grep '^version:' pubspec.yaml | sed 's/version: *//; s/+.*//')"
    dmg="build/dmg/mesh-market_${version}.dmg"

    rm -rf build/dmg
    mkdir -p build/dmg
    hdiutil create -volname "Mesh Market" -srcfolder "$app" \
      -ov -format UDZO "$dmg"
    echo "Built $dmg"

buy:
    #!/usr/bin/env bash
    set -euo pipefail
    version="$(grep '^version:' pubspec.yaml | sed 's/version: *//; s/+.*//')"
    case "$(uname -s)" in
     Linux)
      just deb
      deb="build/deb/mesh-market_${version}_amd64.deb"
      sudo dpkg -i "$deb" || sudo apt-get install -f -y
      sudo update-desktop-database -q 2>/dev/null || true
      sudo gtk-update-icon-cache -q /usr/share/icons/hicolor 2>/dev/null || true
      echo "Installed mesh-market $version"
      ;;
     Darwin)
      just dmg
      app="$(find build/macos/Build/Products/Release -maxdepth 1 -name '*.app' | head -1)"
      rm -rf "/Applications/$(basename "$app")"
      cp -R "$app" /Applications/
      echo "Installed $(basename "$app") to /Applications"
      ;;
     MINGW*|MSYS*|CYGWIN*|Windows*)
      flutter build windows --release
      dest="$LOCALAPPDATA/Programs/MeshMarket"
      rm -rf "$dest"
      mkdir -p "$dest"
      cp -R build/windows/x64/runner/Release/. "$dest/"
      echo "Installed Mesh Market to $dest"
      ;;
     *)
      echo "Unsupported platform: $(uname -s)" >&2
      exit 1
      ;;
    esac

clean:
    flutter clean
