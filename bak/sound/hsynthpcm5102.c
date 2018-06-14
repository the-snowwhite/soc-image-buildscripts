/*
* HSYNTH7002 Soc Synthesizer dummy codec driver
*
* Copyright 2017 Holotronic
*  Michael Brown (the-snowwhite) <producer@holotronic.dk>
*  based on hsynth7002.c
*
* Licensed under the GPL-2.
*/

#include <linux/init.h>
#include <linux/module.h>
#include <linux/of.h>
#include <linux/platform_device.h>

#include <sound/soc.h>

static const struct snd_soc_dapm_widget hsynthpcm5102_widgets[] = {
    SND_SOC_DAPM_OUTPUT("PCMOUT"),
    SND_SOC_DAPM_INPUT("HSYNTH"),
};

static const struct snd_soc_dapm_route hsynthpcm5102_routes[] = {
	{ "Playback", NULL, "PCMOUT" },
    { "Capture", NULL, "HSYNTH" },
};

static int hsynthpcm5102_set_dai_fmt(struct snd_soc_dai *dai, unsigned int fmt)
{
    switch (fmt & SND_SOC_DAIFMT_MASTER_MASK) {
    case SND_SOC_DAIFMT_CBS_CFS:
        break;
    default:
        return -EINVAL;
    }

    switch (fmt & SND_SOC_DAIFMT_INV_MASK) {
    case SND_SOC_DAIFMT_NB_NF:
        break;
    default:
        return -EINVAL;
    }

    switch (fmt & SND_SOC_DAIFMT_FORMAT_MASK) {
    case SND_SOC_DAIFMT_I2S:
    case SND_SOC_DAIFMT_DSP_A:
        break;
    default:
        return -EINVAL;
    }

    return 0;
}

static const struct snd_soc_dai_ops hsynthpcm5102_dai_ops = {
    .set_fmt = hsynthpcm5102_set_dai_fmt,
};

static struct snd_soc_dai_driver hsynthpcm5102_dai = {
	.name = "hsynthpcm5102-hifi",
	.playback = {
		.stream_name = "Playback",
		.channels_min = 2,
		.channels_max = 2,
		.rates = SNDRV_PCM_RATE_8000_96000,
		.formats = SNDRV_PCM_FMTBIT_S16_LE | SNDRV_PCM_FMTBIT_S20_3LE |
			SNDRV_PCM_FMTBIT_S24_LE | SNDRV_PCM_FMTBIT_S32_LE,
	},
    .capture = {
		.stream_name = "Capture",
		.channels_min = 2,
		.channels_max = 2,
		.rates = SNDRV_PCM_RATE_8000_96000,
		.formats = SNDRV_PCM_FMTBIT_S16_LE |
		SNDRV_PCM_FMTBIT_S24_LE | SNDRV_PCM_FMTBIT_S32_LE,
		.sig_bits = 20,
	},
//	.ops = &hsynthpcm5102_dai_ops,
};

static const struct snd_soc_codec_driver hsynthpcm5102_codec_driver = {
    .component_driver = {
        .dapm_widgets = hsynthpcm5102_widgets,
        .num_dapm_widgets = ARRAY_SIZE(hsynthpcm5102_widgets),
        .dapm_routes = hsynthpcm5102_routes,
        .num_dapm_routes = ARRAY_SIZE(hsynthpcm5102_routes),
    },
};

static int hsynthpcm5102_probe(struct platform_device *pdev)
{
    return snd_soc_register_codec(&pdev->dev, &hsynthpcm5102_codec_driver,
            &hsynthpcm5102_dai, 1);
}

static int hsynthpcm5102_remove(struct platform_device *pdev)
{
    snd_soc_unregister_codec(&pdev->dev);
    return 0;
}

//#ifdef CONFIG_OF
static const struct of_device_id hsynthpcm5102_dt_ids[] = {
    { .compatible = "holotr,hsynthpcm5102", },
    { }
};
MODULE_DEVICE_TABLE(of, hsynthpcm5102_dt_ids);
//#endif

static struct platform_driver hsynthpcm5102_driver = {
    .driver = {
        .name = "hsynthpcm5102",
        .of_match_table	= of_match_ptr(hsynthpcm5102_dt_ids),
    },
    .probe = hsynthpcm5102_probe,
    .remove = hsynthpcm5102_remove,
};
module_platform_driver(hsynthpcm5102_driver);

MODULE_AUTHOR("Michael Brown <producer@holotronic.dk>");
MODULE_DESCRIPTION("HSYNTH7002 Dummy Soc synthesizer codec-driver driver");
MODULE_LICENSE("GPL v2");
