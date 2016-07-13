class Glfw3 < Formula
  desc "Multi-platform library for OpenGL applications"
  homepage "http://www.glfw.org/"
  url "https://github.com/glfw/glfw/archive/3.2.tar.gz"
  sha256 "cb3aab46757981a39ae108e5207a1ecc4378e68949433a2b040ce2e17d8f6aa6"

  bottle do
    cellar :any
    sha256 "c3f721491e4a3f07c1493f4fa2f90569df29d07b0e40c66ad74b7e5733030494" => :el_capitan
    sha256 "8dfe6bdaa7e9d51c231dc2253ff058e1bf1414ca7d886962604fd9769e55bd9d" => :yosemite
    sha256 "8913519230f28552e88591460316a97dd8f942bdb552de5ca7e2a68702b9e045" => :mavericks
  end

  option :universal
  option "without-shared-library", "Build static library only (defaults to building dylib only)"
  option "with-examples", "Build examples"
  option "with-test", "Build test programs"

  depends_on "cmake" => :build

  deprecated_option "build-examples" => "with-examples"
  deprecated_option "static" => "without-shared-library"
  deprecated_option "build-tests" => "with-test"
  deprecated_option "with-tests" => "with-test"

  def install
    ENV.universal_binary if build.universal?

    # make library name consistent
    inreplace "CMakeLists.txt", /set\(GLFW_LIB_NAME\sglfw\)\n.*else\(\)\n/, ""

    args = std_cmake_args + %W[
      -DGLFW_USE_CHDIR=TRUE
      -DGLFW_USE_MENUBAR=TRUE
    ]
    args << "-DGLFW_BUILD_UNIVERSAL=TRUE" if build.universal?
    args << "-DBUILD_SHARED_LIBS=TRUE" if build.with? "shared-library"
    args << "-DGLFW_BUILD_EXAMPLES=TRUE" if build.with? "examples"
    args << "-DGLFW_BUILD_TESTS=TRUE" if build.with? "test"
    args << "."

    system "cmake", *args
    system "make", "install"
    libexec.install Dir["examples/*"] if build.with? "examples"
    libexec.install Dir["tests/*"] if build.with? "tests"
  end

  test do
    (testpath/"test.c").write <<-EOS.undent
      #define GLFW_INCLUDE_GLU
      #include <GLFW/glfw3.h>
      #include <stdlib.h>
      int main()
      {
        if (!glfwInit())
          exit(EXIT_FAILURE);
        glfwTerminate();
        return 0;
      }
    EOS
    system ENV.cc, "-I#{include}", "-L#{lib}", "-lglfw3",
           testpath/"test.c", "-o", "test"
    system "./test"
  end
end
