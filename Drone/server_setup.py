#!/usr/bin/env python3
# A simple script to convert a json format file to bash script to run docker
from shlex import quote,split


def parseVal(val, caseFormatter=lambda x: x):
    '''
    Convert a json type to a str
    '''
    if isinstance(val,str):
        return val
    elif isinstance(val, bool):
        if val:
            return caseFormatter('true')
        else:
            return caseFormatter('false')
    elif isinstance(val, int):
        return '{:d}'.format(val)
    elif isinstance(val, list):
        d = [parseVal(i) for i in val]
        return '({:s})'.format(' '.join(d))
    else:
        raise ValueError('Don''t support float')


def parseEnvDict(d, prefix=''):
    '''
    Convert a dict to a list of str
    Example:
    d =
    {
        'a': {
            'b': 1
        },
        'c': 'abc'
    }

    prefix = P

    is converted to

    ['P_A_B=1', 'P_C=abc']
    '''
    r = []
    for k in d:
        if prefix:
            name = '{:s}_{:s}'.format(prefix.upper(), k.upper())
        else:
            name = '{:s}'.format(k.upper())

        if isinstance(d[k], dict):
            r += parseEnvDict(d[k], prefix=name)
        else:
            # print('{:s}={:s}'.format(name,parseVal(d[k], lambda x: x.upper())))
            r.append('{:s}={:s}'.format(name,parseVal(d[k])))
    return r


class Docker:
    '''
    A class for docker server settings
    '''
    def __init__(self, d):
        if isinstance(d, dict):
            self.root = d
        elif isinstance(d, str):
            with open(d, 'r') as f:
                self.root = json.load(f)

        self.name = self.root['name']
        if self.root['type'].lower() != 'docker':
            raise ValueError('The type of server is incorrect')

        # comment before the bash scripts
        self.image = self.root['image']
        self.comment = ['# Server: {}'.format(self.name), '# Type: {}'.format('docker')]

        # parse environmental variable
        self.conf = self.root['conf']
        if 'env' not in self.conf:
            self.env = None
        else:
            self.env = parseEnvDict(self.conf['env'])

    def writeENV(self, name):
        '''
        Write self.env to a file '${name}.list'
        '''
        with open('{:s}.list'.format(name), 'w', encoding='utf-8', newline='\n') as f:
            for i in self.env[:-1]:
                f.write('{}\n'.format(i))
            f.write(self.env[-1])

    def exportBash(self, type='run'):
        '''
        Export a list containing lines in bash script

        You need to add '\n' manually
        '''
        r = self.comment[:]
        if type == 'run':
            cmd = ['docker','run']
            for k,v in self.conf.items():
                if k != '0' and k != 'env':
                    key = '--{:s}'.format(k) if len(k) > 1 else '-{:s}'.format(k)
                    if isinstance(v, (str,bool,int,float)):
                        cmd.append('{:s}={:}'.format(key,parseVal(v)))
                    elif isinstance(v, list):
                        for v2 in v:
                            if len(v2) != 2:
                                raise ValueError('Conf {:} should be pairs'.format(k))
                            else:
                                cmd.append('{:s}={:}:{:}'.format(key, quote(v2[0]), quote(v2[1])))
            # env
            if self.env:
                rd = ['--env={}'.format(quote(i)) for i in self.env]
                cmd += rd
            # positional arguments
            if '0' in self.conf:
                if self.conf['0']:
                    if isinstance(self.conf['0'], list):
                        for val in self.conf['0'][:-1]:
                            cmd.append('{:s} \\'.format(val))
                        val = self.conf['0'][-1]
                        cmd.append('{:s}'.format(val))
                    elif isinstance(self.conf['0'], (str,int,float)):
                        cmd.append('{:s}'.format(parseVal(self.conf['0'])))
            cmd.append('{:s}'.format(self.image))

            r.append(' '.join(cmd))
            # you can use shlex.split to split the command
        elif type == 'preinstall':
            r.append('docker pull {:}'.format(quote(self.image)))
        elif type == 'start':
            r.append('docker start {:}'.format(quote(self.conf['name'])))
        elif type == 'stop':
            r.append('docker stop {:}'.format(quote(self.conf['name'])))
        # a new line
        r.append('')

        return r


def splitLongBash(d, indent=4, maxlen=80, endFile=False):
    ds = split(d)
    if not ds:
        return [d] if endFile else [d + '\n']
    do = [ds[0]]
    l0 = len(ds[0])
    ps = ' \\'
    maxlen -= len(ps)

    li = len(ds[0])
    i = 1
    j = 0
    while i < len(ds):
        di = ds[i]
        if li + 1 + len(di) <= maxlen:
            do[j] += ' ' + di
            li = len(do[j])
        else:
            do.append(' '*indent + di)
            j += 1
        i += 1

    for i in range(len(do)-1):
        do[i] += ps+'\n'
    if not endFile:
        do[-1] += '\n'
    return do


def writeBash(l, name):
    with open('{:}.sh'.format(name), 'w', encoding='utf-8', newline='\n') as f:
        f.write('#!/bin/bash -e\n\n')
        for d in l[:-1]:
            ds = splitLongBash(d)
            for di in ds:
                f.write('{:s}'.format(di))
        ds = splitLongBash(l[-1], endFile=True)
        for di in ds:
            f.write('{:s}'.format(di))


if __name__ == "__main__":
    import json
    import sys
    print(sys.argv)
    if len(sys.argv) < 2:
        jsonConf = 'server_setup.json'
    else:
        jsonConf = sys.argv[1]
    with open(jsonConf, 'r') as f:
        j = json.load(f)

    if len(sys.argv) < 3:
        runType = 'run'
    else:
        runType = sys.argv[2]

    # parse servers
    server = []
    server_name = []
    for ji in j:
        if ji['type'].lower() == 'docker':
            if ji['name'] in server_name:
                raise ValueError('There are more than one Server:{:}'.format(ji['name']))

            s = Docker(ji)
            server.append(s)
            server_name.append(ji['name'])
            #s.writeENV(ji['name'])

    # generate bash script list
    bashScript = []
    for s in server:
        bashScript += s.exportBash(runType)

    # write bash script
    writeBash(bashScript, 'docker_run')
