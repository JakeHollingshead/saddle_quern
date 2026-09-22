"""Free-function helper that turns inventory counts into a text report."""


def format_low_stock(counts, threshold):
    assert threshold >= 0, "threshold must be non-negative"
    low = [sku for sku, n in counts.items() if n < threshold]
    assert isinstance(low, list), "low must be a list"
    if not low:
        return "All stock levels are healthy."
    lines = [f"{sku}: {counts[sku]} left" for sku in sorted(low)]
    return "Low stock:\n" + "\n".join(lines)
