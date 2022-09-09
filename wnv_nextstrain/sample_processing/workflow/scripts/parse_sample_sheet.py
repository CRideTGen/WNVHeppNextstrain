import csv
import pathlib
import re

from pydantic import BaseModel, ValidationError, validator
from typing import Optional, Union

FIELDNAMES = [
    'sample_id',
    'sample_name',
    'sample_plate',
    'sample_well',
    'i7_index_id',
    'index',
    'i5_index_id',
    'index2',
    'sample_project',
    'description'
]


class Sample(BaseModel):
    sample_name: str
    sdsi: Union[int, str]

    @validator('sample_name')
    def sample_name_not_empty_str(cls, v):
        if not v:
            raise ValueError(f"Missing sample name")
        return v

    @validator("sdsi")
    def sdsi_name_or_sample(cls, v):
        match = None
        sdsi_index = 0

        if "sdsi" in v.lower() and "broad" in v.lower():
            match = re.search(r"sdsi_broad_(\d{1,3})", v.lower())
            sdsi_index = int(match.group(1))

        if "sdsi" in v.lower() and "tg_" in v.lower():
            match = re.search(r"sdsi_tg_r(\d{1,3})-g(\d{1,2})", v.lower())
            g1 = int(match.group(1))*10
            g2 = int(match.group(2))
            sdsi_index = g1 + g2 + 10

        if match:
            return sdsi_index
        else:
            return -1


def read_sample_sheet(input_dir: pathlib.Path, fieldnames: list) -> dict[str, Sample]:
    sample_dict = dict()

    sample_sheet_csv = input_dir.joinpath("SampleSheet.csv")

    with open(sample_sheet_csv, 'r') as sample_sheet:
        reader = csv.DictReader(sample_sheet, fieldnames=fieldnames, delimiter=',')

        # skipping header
        row = next(reader)

        while "Sample_ID" != row["sample_id"]:
            row = next(reader)

        for row in reader:
            sample_name = row["sample_name"]
            sdsi_name = row["description"]

            sample = Sample(sample_name=sample_name,
                            sdsi=sdsi_name)

            sample_dict[sample_name] = sample

        return sample_dict


if __name__ == "__main__":
    pass
