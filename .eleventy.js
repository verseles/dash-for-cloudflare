const { execSync } = require('child_process');

module.exports = function(eleventyConfig) {
  // After Eleventy builds, run Flutter build
  eleventyConfig.on('eleventy.after', async () => {
    console.log('==> Eleventy done, starting Flutter build...');
    
    const FLUTTER_CACHE = '.cache/flutter';
    
    // Check if Flutter is cached
    try {
      require('fs').accessSync(`${FLUTTER_CACHE}/bin/flutter`);
      console.log('==> Using cached Flutter SDK');
    } catch {
      console.log('==> Downloading Flutter SDK (not in cache)...');
      execSync(`mkdir -p .cache && git clone --depth 1 -b stable https://github.com/flutter/flutter.git ${FLUTTER_CACHE}`, { stdio: 'inherit' });
    }
    
    const env = { ...process.env, PATH: `${process.env.PATH}:${process.cwd()}/${FLUTTER_CACHE}/bin` };
    
    console.log('==> Flutter version:');
    execSync('flutter --version', { stdio: 'inherit', env });
    
    console.log('==> Installing dependencies...');
    execSync('flutter pub get', { stdio: 'inherit', env });
    
    console.log('==> Generating code (Freezed, Retrofit)...');
    execSync('dart run build_runner build --delete-conflicting-outputs', { stdio: 'inherit', env });
    
    console.log('==> Building web release...');
    execSync('flutter build web --release --output=_site', { stdio: 'inherit', env });
    
    console.log('==> Build complete!');
  });

  return {
    dir: {
      input: 'src',
      output: '_site'
    }
  };
};
