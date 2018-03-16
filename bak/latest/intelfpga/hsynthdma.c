/*
* Copyright (C) 2017 Michael Brown (the-snowwhite) <producer@holotronic.dk>
* Largely based on opencores_i2s.c by Bjarne Steinsbo <bsteinsbo@gmail.com>.
*
* Licensed under the GPL-2.
*/

#include <linux/clk.h>
#include <linux/init.h>
#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/of.h>
#include <linux/platform_device.h>
#include <linux/regmap.h>
#include <linux/slab.h>

#include <sound/core.h>
#include <sound/pcm.h>
#include <sound/dmaengine_pcm.h>
#include <sound/pcm_params.h>
#include <sound/soc.h>

//#define DAC_FIFO_ADDR  0x00
#define STATUS_ADDR    0x04
#define CMD_ADDR       0x08
#define ADC_FIFO_ADDR  0x00

/* Commands to register at CMD_ADDR */
#define PB_FIFO_CLEAR  BIT(0)
#define PB_ENABLE      BIT(1)
#define CAP_FIFO_CLEAR BIT(2)
#define CAP_ENABLE     BIT(3)

#define CLK_CTRL1      0x00
#define CLK_CTRL2      0x04

/* Bit-fields of clk control register 1 */
#define CLK_MASTER_SLAVE  BIT(0)
#define CLK_SEL_48_44    BIT(1)
#define MCLK_DIV_SHIFT   (24)
#define MCLK_DIV_MASK    GENMASK(MCLK_DIV_SHIFT + 7, MCLK_DIV_SHIFT)
#define BCLK_DIV_SHIFT   (16)
#define BCLK_DIV_MASK    GENMASK(BCLK_DIV_SHIFT + 7, BCLK_DIV_SHIFT)
/* Bit-fields of clk control register 2 */
#define PB_LRC_DIV_SHIFT  (8)
#define PB_LRC_DIV_MASK          GENMASK(PB_LRC_DIV_SHIFT + 7, PB_LRC_DIV_SHIFT)
#define CAP_LRC_DIV_SHIFT (0)
#define CAP_LRC_DIV_MASK  GENMASK(CAP_LRC_DIV_SHIFT + 7, CAP_LRC_DIV_SHIFT)

/* The frame size is not configurable */
#define BITS_PER_FRAME 64

struct holotr_dmalink {
    struct regmap *regmap_data;
    struct regmap *regmap_clk;
//       struct clk *clk48;
    struct clk *clk44;

    struct snd_soc_dai_driver dai_driver;

    struct snd_dmaengine_dai_dma_data capture_dma_data;
//       struct snd_dmaengine_dai_dma_data playback_dma_data;

    struct snd_ratnum ratnum;
    struct snd_pcm_hw_constraint_ratnums rate_constraints;
};

static int holotr_dmalink_trigger(struct snd_pcm_substream *substream, int cmd,
    struct snd_soc_dai *dai)
{
    struct holotr_dmalink *dmalink = snd_soc_dai_get_drvdata(dai);
    unsigned int mask, val;

    if (substream->stream == SNDRV_PCM_STREAM_CAPTURE)
            mask = CAP_ENABLE;
    else
            mask = PB_ENABLE;

    switch (cmd) {
    case SNDRV_PCM_TRIGGER_START:
    case SNDRV_PCM_TRIGGER_RESUME:
    case SNDRV_PCM_TRIGGER_PAUSE_RELEASE:
            val = mask;
            break;
    case SNDRV_PCM_TRIGGER_STOP:
    case SNDRV_PCM_TRIGGER_SUSPEND:
    case SNDRV_PCM_TRIGGER_PAUSE_PUSH:
            val = 0;
            break;
    default:
            return -EINVAL;
    }

    regmap_update_bits(dmalink->regmap_data, CMD_ADDR, mask, val);
//     regmap_write(dmalink->regmap_data, CMD_ADDR, val);

    dev_dbg(dai->dev, "trigger %x\n", val);
    return 0;
}

static int divisor_value(unsigned long xtal_rate, unsigned long rate, int shift)
{
    return ((xtal_rate / rate / 2) >> shift) - 1;
}

static int holotr_dmalink_hw_params(struct snd_pcm_substream *substream,
    struct snd_pcm_hw_params *params, struct snd_soc_dai *dai)
{
    struct holotr_dmalink *dmalink = snd_soc_dai_get_drvdata(dai);
    unsigned long xtal_rate;
    int lrclk_div;
    int mclk_div;
    int bclk_div;
    int mask, val;
    int mask2, val2;

    dev_dbg(dai->dev, "hw_params fmt=0x%x\n", params_format(params));
    dev_dbg(dai->dev, "hw_params rate=%d\n", params_rate(params));
    if (params_format(params) != SNDRV_PCM_FORMAT_S32_LE)
            return -EINVAL;

    if ((params_rate(params) % 44100) == 0) {
        val = CLK_SEL_48_44;
        xtal_rate = clk_get_rate(dmalink->clk44);
        mclk_div = divisor_value(xtal_rate, 16934400, 0); /* fs*384 at 44.1kHz */
    }
//    else if ((params_rate(params) % 48000) == 0) {
//      val = 0;
//      xtal_rate = clk_get_rate(dmalink->clk48);
//      mclk_div = divisor_value(xtal_rate, 12288000, 0); /* fs*256 at 48kHz */
//    }
    else
        return -EINVAL;

    mask = CLK_SEL_48_44;
    mask2 = 0;

    lrclk_div = divisor_value(xtal_rate, params_rate(params), 4);
    bclk_div = divisor_value(xtal_rate, params_rate(params) * BITS_PER_FRAME, 0);
    dev_dbg(dai->dev, "hw_params mclk_div=%d\n", mclk_div);
    dev_dbg(dai->dev, "hw_params lrclk_div=%d\n", lrclk_div);
    dev_dbg(dai->dev, "hw_params bclk_div=%d\n", bclk_div);
    val |= mclk_div << MCLK_DIV_SHIFT;
    mask |= MCLK_DIV_MASK;
    val |= bclk_div << BCLK_DIV_SHIFT;
    mask |= BCLK_DIV_MASK;
    regmap_update_bits(dmalink->regmap_clk, CLK_CTRL1, mask, val);
    dev_dbg(dai->dev, "hw_params mask=0x%x val=0x%x\n", mask, val);
    if (substream->stream == SNDRV_PCM_STREAM_CAPTURE) {
        val2 = lrclk_div << CAP_LRC_DIV_SHIFT;
        mask2 = CAP_LRC_DIV_MASK;
    } else {
        val2 = lrclk_div << PB_LRC_DIV_SHIFT;
        mask2 = PB_LRC_DIV_MASK;
    }
    regmap_update_bits(dmalink->regmap_clk, CLK_CTRL2, mask2, val2);
    dev_dbg(dai->dev, "hw_params mask2=0x%x val2=0x%x\n", mask2, val2);
    return 0;
}

static int holotr_dmalink_set_fmt(struct snd_soc_dai *dai, unsigned int fmt)
{
    struct holotr_dmalink *dmalink = snd_soc_dai_get_drvdata(dai);
    int val = 0;
    dev_dbg(dai->dev, "set_fmt 0x%x\n", fmt);

    if ((fmt & SND_SOC_DAIFMT_FORMAT_MASK) != SND_SOC_DAIFMT_I2S)
        return -EINVAL;

    if ((fmt & SND_SOC_DAIFMT_INV_MASK) != SND_SOC_DAIFMT_NB_NF)
        return -EINVAL;

    switch (fmt & SND_SOC_DAIFMT_MASTER_MASK) {
    case SND_SOC_DAIFMT_CBM_CFM:
        val = 0;
        break;
    case SND_SOC_DAIFMT_CBS_CFS:
        val = 1;
        break;
    default:
        return -EINVAL;
    }

    dev_dbg(dai->dev, "set_fmt master=%d\n", val);
    regmap_update_bits(dmalink->regmap_clk, 0, CLK_MASTER_SLAVE, val);
    return 0;
}

static int holotr_dmalink_sysclk(struct snd_soc_dai *dai, int clk_id,
    unsigned int freq, int dir)
{
    struct holotr_dmalink *dmalink = snd_soc_dai_get_drvdata(dai);
    int val = SND_SOC_CLOCK_IN ? 1 : 0;
    dev_dbg(dai->dev, "sysclk id=%d freq=%d dir=%d\n", clk_id, freq, dir);
    regmap_update_bits(dmalink->regmap_clk, 0, CLK_MASTER_SLAVE, val);
    return 0;
}

static void holotr_dmalink_shutdown(struct snd_pcm_substream *substream,
    struct snd_soc_dai *dai)
{
    struct holotr_dmalink *dmalink = snd_soc_dai_get_drvdata(dai);
    int mask;
    int val;
    dev_dbg(dai->dev, "shutdown\n");

    if (substream->stream == SNDRV_PCM_STREAM_CAPTURE)
        mask = CAP_ENABLE | CAP_FIFO_CLEAR;
    else
        mask = PB_ENABLE | PB_FIFO_CLEAR;

    val = PB_FIFO_CLEAR | CAP_FIFO_CLEAR;
    regmap_update_bits(dmalink->regmap_data, CMD_ADDR, mask, val);
}

static int holotr_dmalink_dai_probe(struct snd_soc_dai *dai)
{
    struct holotr_dmalink *dmalink = snd_soc_dai_get_drvdata(dai);

    dev_dbg(dai->dev, "dai_probe\n");
//       snd_soc_dai_init_dma_data(dai, &dmalink->playback_dma_data,
    snd_soc_dai_init_dma_data(dai, NULL,
    &dmalink->capture_dma_data);

    return 0;
}

static const struct snd_soc_dai_ops holotr_dmalink_dai_ops = {
    .set_sysclk = holotr_dmalink_sysclk,
    .set_fmt = holotr_dmalink_set_fmt,
    .shutdown = holotr_dmalink_shutdown,
    .hw_params = holotr_dmalink_hw_params,
    .trigger = holotr_dmalink_trigger,
};

static struct snd_soc_dai_driver holotr_dmalink_dai = {
    .probe = holotr_dmalink_dai_probe,
    .capture = {
        .channels_min = 2,
        .channels_max = 2,
//      .rates = SNDRV_PCM_RATE_44100 | SNDRV_PCM_RATE_48000
//      | SNDRV_PCM_RATE_88200 | SNDRV_PCM_RATE_96000
//      | SNDRV_PCM_RATE_176400 | SNDRV_PCM_RATE_192000,
        .rates = SNDRV_PCM_RATE_44100,
        .formats = SNDRV_PCM_FMTBIT_S32_LE,
    },
    .ops = &holotr_dmalink_dai_ops,
    .symmetric_rates = 1,
};

static const struct snd_soc_component_driver holotr_dmalink_component = {
    .name = "holotr-dmalink",
};

static const struct regmap_config holotr_dmalink_regmap_data_config = {
    .name = "holotr_dmalink.data",
    .reg_bits = 32,
    .reg_stride = 4,
    .val_bits = 32,
    .max_register = CMD_ADDR,
};

static const struct regmap_config holotr_dmalink_regmap_clk_config = {
    .name = "holotr_dmalink.clk",
    .reg_bits = 32,
    .reg_stride = 4,
    .val_bits = 32,
    .max_register = CLK_CTRL2,
};

static int holotr_dmalink_probe(struct platform_device *pdev)
{
    struct resource *res, *res_clk;
    struct holotr_dmalink *dmalink;
    void __iomem *base;
    int signature;
    int ret;

    dmalink = devm_kzalloc(&pdev->dev, sizeof(*dmalink), GFP_KERNEL);
    if (!dmalink) {
            dev_err(&pdev->dev, "Can't allocate holotr_dmalink\n");
            return -ENOMEM;
    }
    platform_set_drvdata(pdev, dmalink);

    res = platform_get_resource(pdev, IORESOURCE_MEM, 0);
    if (!res) {
            dev_err(&pdev->dev, "No memory resource\n");
            return -ENODEV;
    }
    base = devm_ioremap_resource(&pdev->dev, res);
    if (IS_ERR(base)) {
            dev_err(&pdev->dev, "No ioremap resource\n");
            return PTR_ERR(base);
    }
    printk(KERN_ALERT "holotr_dmalink at %08x\n", (int)base);

    dmalink->regmap_data = devm_regmap_init_mmio(&pdev->dev, base,
            &holotr_dmalink_regmap_data_config);
    if (IS_ERR(dmalink->regmap_data)) {
            dev_err(&pdev->dev, "No regmap_data\n");
            return PTR_ERR(dmalink->regmap_data);
    }

    res_clk = platform_get_resource(pdev, IORESOURCE_MEM, 1);
    if (!res_clk) {
            dev_err(&pdev->dev, "No memory resource\n");
            return -ENODEV;
    }
    base = devm_ioremap_resource(&pdev->dev, res_clk);
    if (IS_ERR(base)) {
            dev_err(&pdev->dev, "No ioremap resource\n");
            return PTR_ERR(base);
    }

    dmalink->regmap_clk = devm_regmap_init_mmio(&pdev->dev, base,
            &holotr_dmalink_regmap_clk_config);
    if (IS_ERR(dmalink->regmap_clk)) {
            dev_err(&pdev->dev, "No regmap_clk\n");
            return PTR_ERR(dmalink->regmap_clk);
    }
/*
    dmalink->clk48 = devm_clk_get(&pdev->dev, "clk48");
    if (IS_ERR(dmalink->clk48)) {
            dev_err(&pdev->dev, "No clk48 clock\n");
            return PTR_ERR(dmalink->clk48);
    }

    ret = clk_prepare_enable(dmalink->clk48);
    if (ret) {
            dev_err(&pdev->dev, "Cannot enable clock\n");
            return ret;
    }
*/
    dmalink->clk44 = devm_clk_get(&pdev->dev, "clk44");
    if (IS_ERR(dmalink->clk44)) {
            dev_err(&pdev->dev, "No clk44 clock\n");
            return PTR_ERR(dmalink->clk44);
    }

    ret = clk_prepare_enable(dmalink->clk44);
    if (ret) {
            dev_err(&pdev->dev, "Cannot enable clock\n");
            return ret;
    }

//       dmalink->playback_dma_data.addr = res->start + DAC_FIFO_ADDR;
//       dmalink->playback_dma_data.addr_width = 4;
//       dmalink->playback_dma_data.maxburst = 1;
    //dmalink->playback_dma_data.maxburst = 2;
//       dev_dbg(&pdev->dev, "probe playback dma addr : %8x\n",
//       dmalink->playback_dma_data.addr);

    dmalink->capture_dma_data.addr = res->start + ADC_FIFO_ADDR;
    dmalink->capture_dma_data.addr_width = 4;
    dmalink->capture_dma_data.maxburst = 1;
    //dmalink->capture_dma_data.maxburst = 2;

/*
    dmalink->ratnum.num = clk_get_rate(dmalink->clk_ref) / 2 / BITS_PER_FRAME;
    dmalink->ratnum.den_step = 1;
    dmalink->ratnum.den_min = 1;
    dmalink->ratnum.den_max = 64;

    dmalink->rate_constraints.rats = &dmalink->ratnum;
    dmalink->rate_constraints.nrats = 1;
*/

    regmap_write(dmalink->regmap_data, CMD_ADDR, PB_FIFO_CLEAR | CAP_FIFO_CLEAR);
    ret = regmap_read(dmalink->regmap_data, STATUS_ADDR, &signature);
    if (ret) {
        dev_err(&pdev->dev, "Cannot read signature\n");
        printk(KERN_ALERT "holotr_dmalink probe signature : %4x\n", signature);
        goto err_clk_disable;
    }
    dev_dbg(&pdev->dev, "probe signature : %4x\n", signature);

    ret = devm_snd_soc_register_component(&pdev->dev, &holotr_dmalink_component,
                                        &holotr_dmalink_dai, 1);
    if (ret) {
        dev_err(&pdev->dev, "Cannot register component\n");
        goto err_clk_disable;
    }

    ret = devm_snd_dmaengine_pcm_register(&pdev->dev, NULL, 0);
    if (ret) {
        dev_err(&pdev->dev, "Cannot register dmaengine\n");
        goto err_clk_disable;
    }

    dev_dbg(&pdev->dev, "probe finishing\n");
    return ret;

err_clk_disable:
//       clk_disable_unprepare(dmalink->clk48);
    clk_disable_unprepare(dmalink->clk44);
    return ret;
}

static const struct of_device_id holotr_dmalink_of_match[] = {
    { .compatible = "holotr,dmalink", },
    {},
};
MODULE_DEVICE_TABLE(of, holotr_dmalink_of_match);

static struct platform_driver holotr_dmalink_driver = {
    .probe = holotr_dmalink_probe,
    .driver = {
        .name = "holotr-dmalink",
//        .owner = THIS_MODULE,
        .of_match_table = holotr_dmalink_of_match,
    },
};
module_platform_driver(holotr_dmalink_driver);

MODULE_AUTHOR("Michael Brown (the-snowwhite) <producer@holotronic.dk");
MODULE_DESCRIPTION("DMA sound driver for soc at https://github.com/the-snowwhite");
MODULE_LICENSE("GPL");
