## Sudo Set Config Var Buildpack

For safety reasons buildpacks use a denylist for config vars. Also buildpacks rely on env vars from their runner (Codon on Heroku) for internal features. You cannot set denylist config vars or use config vars to modify "internal" enviornment variable, but you can with t his buildpack.

This buildpack allows you to set any global environment variable you want. Add it as your first buildpack, then set the environment variable you desire:

```
heroku config:set __SUDO_PATH=this/would/break/everything
```

This buildpack will strip off the `__SUDO_` of the beginning of the environment variable and export `PATH=this/would/break/everything` so the next buildpack picks it up.

Why would you want that behavior? It allows the ability to test a different S3 bucket in the Ruby buildpack for example https://github.com/heroku/heroku-buildpack-ruby/blob/125191fdf57bf80f0cebf1f2d6009f77be6ae99a/lib/language_pack/base.rb#L21.

This buildpack is not designed for production use, it should only ever be used for testing and staging. Use of this buildpack will effectively break any support context with another buildpack. For example if you're using this in production along with the heroku/ruby buildpack, you would need to reproduce the problem without this buildpack before your Heroku could provide support to your application.

