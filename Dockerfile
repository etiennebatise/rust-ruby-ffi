FROM ubuntu:latest

# Install Ruby toolchain
RUN \
  apt update && \
  apt install -y build-essential ruby-full curl
RUN gem install bundle

# Install Rust tool chain
RUN curl https://sh.rustup.rs -sSf | bash -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Get sources
WORKDIR /usr/app
COPY . .

# Build rust lib
WORKDIR /usr/app/lib
# Remove the --release flag during development. The target directory will change
# from target/release to target/debug. Remember to update the ffi_lib path in
# the ruby file.
RUN cargo build --release

# Run ruby code
WORKDIR /usr/app
# Bundle install might fail because of bundle version mismatch
RUN rm Gemfile.lock
RUN bundle install
CMD ["bundle", "exec", "ruby", "main.rb"]

