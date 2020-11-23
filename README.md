<p align="center"><img src="https://avatars3.githubusercontent.com/u/45311177?s=200&v=4"></p>

![Coding standards status](https://github.com/nuxed/translation/workflows/coding%20standards/badge.svg?branch=develop)
![Static analysis status](https://github.com/nuxed/translation/workflows/static%20analysis/badge.svg?branch=develop)
![Unit tests status](https://github.com/nuxed/translation/workflows/unit%20tests/badge.svg?branch=develop)
[![Total Downloads](https://poser.pugx.org/nuxed/translation/d/total.svg)](https://packagist.org/packages/nuxed/translation)
[![Latest Stable Version](https://poser.pugx.org/nuxed/translation/v/stable.svg)](https://packagist.org/packages/nuxed/translation)
[![License](https://poser.pugx.org/nuxed/translation/license.svg)](https://packagist.org/packages/nuxed/translation)

# Nuxed Translation

The Nuxed Translation component provides tools to internationalize your application. 

### Installation

This package can be installed with [Composer](https://getcomposer.org).

```console
$ composer require nuxed/translation
```

### Example

```hack
use namespace Nuxed\Translation;
use namespace Nuxed\Translation\Loader;

<<__EntryPoint>>
async function main(): Awaitable<void> {
  $translator = new Translation\Translator('en');
  $translator->addLoader('json', new Loader\JsonLoader());

  // "translation/messages.en.json"s content : 
  // {
  //   "hello": "Hello {name}"
  // }
  $translator->addResource('json', 'translation/messages.en.json', 'en');

  // "translation/messages.fr.json"s content : 
  // {
  //   "hello": "Bonjour {name}"
  // }
  $translator->addResource('json', 'translation/messages.fr.json', 'fr');

  echo await $translator->trans('hello', dict['name' => 'saif']); // Hello saif

  echo await $translator->trans('hello', dict['name' => 'saif'], 'fr'); // Bonjour saif
}
```

---

### Security

For information on reporting security vulnerabilities in Nuxed, see [SECURITY.md](SECURITY.md).

---

### License

Nuxed is open-sourced software licensed under the MIT-licensed.
