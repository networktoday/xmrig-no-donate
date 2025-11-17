# XMRig No-Donate - Monero Miner
# Build from source with 0% donation
FROM debian:trixie-slim AS builder

# Install build dependencies
RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    cmake \
    libuv1-dev \
    libssl-dev \
    libhwloc-dev \
    && rm -rf /var/lib/apt/lists/*

# Clone XMRig source code
ARG XMRIG_VERSION=v6.23.0
RUN git clone --branch ${XMRIG_VERSION} --depth 1 https://github.com/xmrig/xmrig.git /xmrig

# Modify source to remove donation
RUN sed -i 's/constexpr const int kDefaultDonateLevel = 1;/constexpr const int kDefaultDonateLevel = 0;/' /xmrig/src/donate.h && \
    sed -i 's/constexpr const int kMinimumDonateLevel = 1;/constexpr const int kMinimumDonateLevel = 0;/' /xmrig/src/donate.h

# Build XMRig
RUN mkdir -p /xmrig/build && cd /xmrig/build && \
    cmake .. \
        -DCMAKE_BUILD_TYPE=Release \
        -DWITH_HWLOC=ON \
        -DWITH_TLS=ON \
        -DWITH_OPENCL=OFF \
        -DWITH_CUDA=OFF && \
    make -j$(nproc)

# Runtime image
FROM debian:trixie-slim

# Install runtime dependencies only
RUN apt-get update && apt-get install -y \
    libssl3t64 \
    libhwloc15 \
    libuv1t64 \
    libstdc++6 \
    && rm -rf /var/lib/apt/lists/*

# Copy compiled binary from builder
COPY --from=builder /xmrig/build/xmrig /usr/local/bin/xmrig
RUN chmod +x /usr/local/bin/xmrig

# Create non-privileged user
RUN useradd -u 1000 -m -s /bin/bash mining

# Switch to non-privileged user
USER mining
WORKDIR /home/mining

# Default command
ENTRYPOINT ["/usr/local/bin/xmrig"]
CMD ["--help"]
