/*
 * hsynth-soc -- SoC audio ( midi for Altera SoC boards
 * Author: Michael Brown the-snowwhite <producer@holotronic.dk>
 *
 * Based on de1-soc-wm8731 by
 *  B. Steinsbo <bsteinsbo@gmail.com>
 *
 * Licensed under the GPL-2.
 */

#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/clk.h>
#include <linux/platform_device.h>
#include <linux/of.h>
#include <linux/uaccess.h>
#include <linux/ioport.h>
#include <linux/io.h>

#include <sound/core.h>
#include <sound/seq_kernel.h>
#include <sound/rawmidi.h>
#include <sound/initval.h>
#include <sound/pcm.h>
#include <sound/pcm_params.h>
#include <sound/soc.h>

#define SYNTHSOCSOUND_LOG_PREFIX "synthsound: "

#define HSYNTH_SYSCLK_MCLK 2
//#define MCLK_RATE_48K 12288000 /* fs*256 */
#define MCLK_RATE_44K 16934400 /* fs*384 */
#define midi_ins 0
#define midi_outs 1

#define MIDIREG_BASE 0xff200000
#define MIDIREG_SIZE PAGE_SIZE
#define MIDIREG_OFFSET 0x50000

#define printe(...) pr_err(SYNTHSOCSOUND_LOG_PREFIX __VA_ARGS__)

static int snd_socmidi_open(struct snd_rawmidi_substream *substream);
static int snd_socmidi_close(struct snd_rawmidi_substream *substream);
static int hmidi_card_probe(struct snd_soc_card *card);
static int hmidi_card_remove(struct snd_soc_card *card);
static void snd_socmidi_transmit(unsigned char data);
static void snd_socmidi_output_trigger(struct snd_rawmidi_substream *substream, int);
static int hsound_midi_init(struct snd_card *card);

void *midireg_mem;

static int snd_socmidi_open(struct snd_rawmidi_substream *substream)
{
    return 0;
}

static int snd_socmidi_close(struct snd_rawmidi_substream *substream)
{
    return 0;
}

static int hmidi_card_probe(struct snd_soc_card *card)
{
    int err;

    err = hsound_midi_init(card->snd_card);

    if (err < 0) {
        //		dev_dbg(&pdev->dev,"hsound_midi_init failed: %d\n", err);
        return err;
    }

    return 0;
}

static int hmidi_card_remove(struct snd_soc_card *card)
{
    return 0;
}

static void snd_socmidi_transmit(unsigned char data){

    iowrite8(data, midireg_mem);

}

static void snd_socmidi_output_trigger(struct snd_rawmidi_substream *substream, int up) {

    if (!up)
        return;

    while (1) {
        unsigned char data;
        if (snd_rawmidi_transmit(substream, &data, 1) != 1)
            break; /* no more data */
        snd_socmidi_transmit(data);
    }
}

static struct snd_rawmidi *g_rmidi;

static struct snd_rawmidi_ops snd_socmidi_output_ops = {
    .open = snd_socmidi_open,
    .close = snd_socmidi_close,
    .trigger = snd_socmidi_output_trigger,
};

static void pisnd_get_port_info(struct snd_rawmidi *rmidi, int number, struct snd_seq_port_info *seq_port_info)
{
    seq_port_info->type =
    SNDRV_SEQ_PORT_TYPE_MIDI_GENERIC |
    SNDRV_SEQ_PORT_TYPE_HARDWARE |
    SNDRV_SEQ_PORT_TYPE_PORT;
    seq_port_info->midi_voices = 0;
}

static struct snd_rawmidi_global_ops hsnd_global_ops = {.get_port_info = pisnd_get_port_info, };

static int hsound_midi_init(struct snd_card *card)
{
    int err;
    struct resource *res;

    err = snd_rawmidi_new(card, "SocMIDI", 0, midi_outs, midi_ins, &g_rmidi);

    if (err < 0) {
        printe("snd_rawmidi_new failed: %d\n", err);
        return err;
    }

    strcpy(g_rmidi->name, "Holosynth MIDI ");

    g_rmidi->info_flags = SNDRV_RAWMIDI_INFO_OUTPUT;
    // rmidi->info_flags = SNDRV_RAWMIDI_INFO_OUTPUT |
    //                     SNDRV_RAWMIDI_INFO_INPUT |
    //                     SNDRV_RAWMIDI_INFO_DUPLEX;

    g_rmidi->ops = &hsnd_global_ops;

    g_rmidi->private_data = (void *)0;

    snd_rawmidi_set_ops(g_rmidi, SNDRV_RAWMIDI_STREAM_OUTPUT, &snd_socmidi_output_ops);
    //    snd_rawmidi_set_ops(rmidi, SNDRV_RAWMIDI_STREAM_INPUT, &snd_socmidi_input_ops);

    res = request_mem_region((MIDIREG_BASE + MIDIREG_OFFSET), MIDIREG_SIZE, "MIDIREG");
    if (res == NULL) {
        return -EBUSY;
    }

    midireg_mem = ioremap((MIDIREG_BASE + MIDIREG_OFFSET), MIDIREG_SIZE);
    if (midireg_mem == NULL) {
        release_mem_region(MIDIREG_BASE, MIDIREG_SIZE);
        return -EFAULT;
    }

    return 0;
}

static const struct snd_soc_dapm_widget soc_dapm_widgets[] = {
    SND_SOC_DAPM_LINE("Hsynth in", NULL),
};

static const struct snd_soc_dapm_route intercon[] = {
    {"PDM_DAT", NULL, "Hsynth in"},
};

static int soc_hsynth_init(struct snd_soc_pcm_runtime *rtd)
{
    struct snd_soc_dai *codec_dai = rtd->codec_dai;
    struct snd_soc_dai *cpu_dai = rtd->cpu_dai;
    struct device *dev = rtd->card->dev;
    unsigned int fmt;
    int ret;

    dev_dbg(dev, "init\n");

    fmt = SND_SOC_DAIFMT_I2S | SND_SOC_DAIFMT_NB_NF |
    SND_SOC_DAIFMT_CBS_CFS;

    /* set cpu DAI configuration */
    ret = snd_soc_dai_set_fmt(cpu_dai, fmt);
    if (ret < 0)
        return ret;

    /* set codec DAI configuration */
    ret = snd_soc_dai_set_fmt(codec_dai, fmt);
    if (ret < 0)
        return ret;

    return 0;
}

static struct snd_soc_dai_link hsynth_soc_dai = {
    .name = "HSYNTH",
    .stream_name = "HSYNTH PCM",
    .cpu_dai_name = "ff200000.dmalink",
    .codec_dai_name = "hsynth7002-hifi",
    .init = soc_hsynth_init,
    .platform_name = "socsynth",
    .codec_name = "hsynth7002.hsynth",
};

static struct snd_soc_card snd_soc_hsynth_soc = {
    .name = "HOLOSYNTHV",
    .owner = THIS_MODULE,
    .dai_link = &hsynth_soc_dai,
    .num_links = 1,

    .probe        = hmidi_card_probe,
    .remove       = hmidi_card_remove,

    .dapm_widgets = soc_dapm_widgets,
    .num_dapm_widgets = ARRAY_SIZE(soc_dapm_widgets),
    .dapm_routes = intercon,
    .num_dapm_routes = ARRAY_SIZE(intercon),
};

static int hsynth_soc_audio_probe(struct platform_device *pdev)
{
    struct device_node *np = pdev->dev.of_node;
    struct device_node *codec_np, *cpu_np;
    struct snd_soc_card *card = &snd_soc_hsynth_soc;
    int ret;

    if (!np) {
        return -ENODEV;
    }

    card->dev = &pdev->dev;

    /* Parse codec info */
    hsynth_soc_dai.codec_name = NULL;
    codec_np = of_parse_phandle(np, "audio-codec", 0);
    if (!codec_np) {
        dev_err(&pdev->dev, "codec info missing\n");
        return -EINVAL;
    }
    hsynth_soc_dai.codec_of_node = codec_np;

    /* Parse dai and platform info */
    hsynth_soc_dai.cpu_dai_name = NULL;
    hsynth_soc_dai.platform_name = NULL;
    cpu_np = of_parse_phandle(np, "dmalink-controller", 0);
    if (!cpu_np) {
        dev_err(&pdev->dev, "dai and pcm info missing\n");
        return -EINVAL;
    }
    hsynth_soc_dai.cpu_of_node = cpu_np;
    hsynth_soc_dai.platform_of_node = cpu_np;

    of_node_put(codec_np);
    of_node_put(cpu_np);

    ret = snd_soc_register_card(card);
    if (ret) {
        dev_err(&pdev->dev, "snd_soc_register_card() failed\n");
    }

    return ret;
}

static int soc_audio_remove(struct platform_device *pdev)
{
    struct snd_soc_card *card = platform_get_drvdata(pdev);

    snd_soc_unregister_card(card);

    return 0;
}

static const struct of_device_id soc_hsynth_dt_ids[] = {
    { .compatible = "holotr,socsynth-audio", },
    { }
};
MODULE_DEVICE_TABLE(of, soc_hsynth_dt_ids);

static struct platform_driver soc_audio_driver = {
    .driver = {
        .name	= "soc-synth-audio",
        .owner	= THIS_MODULE,
        .of_match_table = of_match_ptr(soc_hsynth_dt_ids),
    },
    .probe	= hsynth_soc_audio_probe,
    .remove	= soc_audio_remove,
};

module_platform_driver(soc_audio_driver);

/* Module information */
MODULE_AUTHOR("Michael Brown (the-snowwhite) <producer@holotronic.dk>");
MODULE_DESCRIPTION("ALSA SoC HOLOSYNTHV");
MODULE_LICENSE("GPL");
