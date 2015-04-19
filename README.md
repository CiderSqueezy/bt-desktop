## Install dependencies
Clone this repo and then after entering the new directory run `npm install`.

You'll also need to have gulp installed globally: `npm install -g gulp`

## Development
Run in the root of your directory: `gulp watch`

This will watch the src directories and build on changes and placed the built css and js files in the public directory. It'll serve everything in the /public directory at localhost:8080

### If styles don't show up
Restart `gulp watch` and reload your browser.

The problem is that I have Webpack setup to package CSS for the browser but we're using Sass/Compass before Webpack. On the first run, the `public/main.css` file is empty as Sass hasn't done its thing yet so Webpack requires an empty file and no styles show up in the browser. On the next start of `gulp watch` the `public/main.css` file *has* been compiled by Sass so styles will now show up in the browser.

# Production build
To build for production, simply run `gulp build`

