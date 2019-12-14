namespace Nuxed\Translation;

use namespace HH\Lib\Str;
use namespace Nuxed\Contract\{Log, Translation};

class LoggingTranslator
  implements Translation\ITranslator, Translation\ILocaleAware, ITranslatorBag {
  public function __construct(
    private Translation\ITranslator $translator,
    private Log\ILogger $logger,
  ) {
    if (!$translator is ITranslatorBag) {
      throw new Exception\InvalidArgumentException(Str\format(
        'The Translator "%s" must implement "%s" interface to be used in "%s".',
        \get_class($translator),
        ITranslatorBag::class,
        static::class,
      ));
    }
  }

  /**
   * {@inheritdoc}
   */
  public async function trans(
    string $id,
    KeyedContainer<string, mixed> $parameters = dict[],
    ?string $domain = null,
    ?string $locale = null,
  ): Awaitable<string> {
    concurrent {
      $trans = await $this->translator
        ->trans($id, $parameters, $domain, $locale);
      await $this->log($id, $domain, $locale);
    }

    return $trans;
  }

  /**
   * {@inheritdoc}
   */
  public async function getCatalogue(
    ?string $locale = null,
  ): Awaitable<MessageCatalogue> {
    return await ($this->translator as ITranslatorBag)->getCatalogue($locale);
  }

  /**
   * Sets the current locale.
   */
  public function setLocale(string $locale): void {
    if (!$this->translator is Translation\ILocaleAware) {
      throw new Exception\InvalidArgumentException(Str\format(
        'The Translator "%s" must implement %s in order to use %s::setLocale().',
        \get_class($this->translator),
        Translation\ILocaleAware::class,
        static::class,
      ));
    }

    $this->translator->setLocale($locale);
  }

  /**
   * Returns the current locale.
   */
  public function getLocale(): string {
    if (!$this->translator is Translation\ILocaleAware) {
      throw new Exception\InvalidArgumentException(Str\format(
        'The Translator "%s" must implement %s in order to use %s::getLocale().',
        \get_class($this->translator),
        Translation\ILocaleAware::class,
        static::class,
      ));
    }

    return $this->translator->getLocale();
  }

  /**
   * Logs for missing translations.
   */
  private async function log(
    string $id,
    ?string $domain,
    ?string $locale,
  ): Awaitable<void> {
    if ($domain is null) {
      $domain = 'messages';
    }

    $id = $id;
    $catalogue = await $this->getCatalogue($locale);
    if ($catalogue->defines($id, $domain)) {
      return;
    }

    if ($catalogue->has($id, $domain)) {
      await $this->logger->debug(
        'Translation use fallback catalogue.',
        dict[
          'id' => $id,
          'domain' => $domain,
          'locale' => $catalogue->getLocale(),
        ],
      );
    } else {
      await $this->logger->warning(
        'Translation not found.',
        dict[
          'id' => $id,
          'domain' => $domain,
          'locale' => $catalogue->getLocale(),
        ],
      );
    }
  }
}
