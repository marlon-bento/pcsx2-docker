FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

RUN apt-get update && apt-get install -y \
    libfuse2 \
    libvulkan1 \
    mesa-vulkan-drivers \
    pulseaudio \
    libgl1 \
    libglx0 \
    libx11-6 \
    libxext6 \
    libopengl0 \
    libegl1 \
    libxcb-cursor0 \
    libxkbcommon-x11-0 \
    libxcb-xinerama0 \
    libxcb-randr0 \
    libxcb-image0 \
    libxcb-keysyms1 \
    libxcb-render-util0 \
    libxcb-shape0 \
    libxcb-sync1 \
    libxcb-icccm4 \
    libsdl2-2.0-0 \
    libudev1 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY "pcsx2-v2.6.3-linux-appimage-x64-Qt.AppImage" /app/pcsx2.AppImage
RUN chmod +x /app/pcsx2.AppImage

ENV APPIMAGE_EXTRACT_AND_RUN=1

CMD ["/app/pcsx2.AppImage"]