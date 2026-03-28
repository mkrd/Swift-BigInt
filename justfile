bench:
    swift build -c release --product Benchmarks -Xswiftc -enable-testing
    .build/release/Benchmarks

test:
    swift build -c release --product Verify -Xswiftc -enable-testing
    .build/release/Verify
